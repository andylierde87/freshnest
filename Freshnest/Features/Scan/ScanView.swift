import PhotosUI
import SwiftData
import SwiftUI

struct ScanView: View {
    @Environment(AppContainer.self) private var container
    @Environment(\.modelContext) private var modelContext
    @Environment(AppRouter.self) private var router

    @State private var viewModel: ScanViewModel?
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var showCamera = false
    @State private var attachBatch: FoodBatch?

    @Query(filter: #Predicate<FoodBatch> { $0.statusRawValue == "active" })
    private var activeBatches: [FoodBatch]

    var body: some View {
        Group {
            if let viewModel {
                content(viewModel: viewModel)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Scan")
        .background(FreshnestColors.background)
        .onAppear {
            if viewModel == nil {
                let newViewModel = ScanViewModel(
                    classifier: container.foodClassifier,
                    analyzer: container.freshnessAnalyzer,
                    repository: container.foodRepository
                )
                viewModel = newViewModel
                #if DEBUG
                if LaunchEnvironment.autoTriggerMockScan, let placeholder = UIImage.solidColorPlaceholder() {
                    newViewModel.imagePicked(placeholder)
                }
                #endif
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraCaptureView(
                onCapture: { image in
                    showCamera = false
                    viewModel?.imagePicked(image)
                },
                onCancel: { showCamera = false }
            )
            .ignoresSafeArea()
        }
        .onChange(of: photosPickerItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                    viewModel?.imagePicked(image)
                }
                photosPickerItem = nil
            }
        }
    }

    @ViewBuilder
    private func content(viewModel: ScanViewModel) -> some View {
        switch viewModel.phase {
        case .idle:
            entryView(viewModel: viewModel)
        case .classifying, .analyzing:
            ProgressView("Analyzing photo…")
                .accessibilityIdentifier("scan.progress")
        case .confirmingFood(let foodID, let confidence, let requiresConfirmation):
            confirmView(viewModel: viewModel, foodID: foodID, confidence: confidence, requiresConfirmation: requiresConfirmation)
        case .manualSelection:
            manualSelectionView(viewModel: viewModel)
        case .result(let data):
            ScanResultView(
                data: data,
                activeBatchesForFood: activeBatches.filter { $0.foodDefinitionID == data.foodID },
                onLooksCorrect: {},
                onLooksFresher: { viewModel.adjustResult(delta: 15) },
                onLooksWorse: { viewModel.adjustResult(delta: -15) },
                onAddToKitchen: { addToKitchen(data: data, image: viewModel.selectedImage) },
                onUpdateExisting: { batch in updateExisting(batch: batch, data: data, image: viewModel.selectedImage) },
                onScanAgain: { viewModel.scanAgain() }
            )
        case .failed(let message):
            ScanFailureView(message: message, onRetry: { viewModel.scanAgain() }, onManual: { viewModel.showManualSelection() })
        }
    }

    private func entryView(viewModel: ScanViewModel) -> some View {
        VStack(spacing: FreshnestSpacing.lg) {
            Spacer()
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 56))
                .foregroundStyle(FreshnestColors.accent)
            Text("Scan your produce")
                .font(FreshnestTypography.sectionTitle)
            Text("Take a photo to estimate ripeness and visible condition on your device.")
                .font(FreshnestTypography.secondary)
                .foregroundStyle(FreshnestColors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, FreshnestSpacing.xl)

            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button("Take Photo") { showCamera = true }
                    .buttonStyle(.freshnestPrimary)
                    .padding(.horizontal, FreshnestSpacing.xxl)
                    .accessibilityIdentifier("scan.takePhotoButton")
            }

            PhotosPicker(selection: $photosPickerItem, matching: .images) {
                Text("Choose from Library")
            }
            .buttonStyle(.freshnestSecondary)
            .padding(.horizontal, FreshnestSpacing.xxl)
            .accessibilityIdentifier("scan.chooseLibraryButton")

            Spacer()
        }
        .padding()
    }

    private func manualSelectionView(viewModel: ScanViewModel) -> some View {
        ManualFoodPickerView(
            title: String(localized: "We're not sure. Choose the food manually."),
            definitions: container.foodRepository.definitions
        ) { definition in
            viewModel.chooseManually(foodID: definition.id)
        }
    }

    private func confirmView(viewModel: ScanViewModel, foodID: String, confidence: Double, requiresConfirmation: Bool) -> some View {
        let definition = container.foodRepository.definition(for: foodID)
        return VStack(spacing: FreshnestSpacing.lg) {
            Spacer()
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 220)
                    .clipShape(RoundedRectangle(cornerRadius: FreshnestRadius.card))
            }
            Text("We think this is:")
                .font(FreshnestTypography.secondary)
                .foregroundStyle(FreshnestColors.secondaryText)
            Text(definition.name)
                .font(FreshnestTypography.largeTitle)
            Text("\(Int((confidence * 100).rounded()))% match")
                .font(FreshnestTypography.secondary)
                .foregroundStyle(FreshnestColors.accent)

            Button("Confirm") { viewModel.confirmFood(foodID: foodID) }
                .buttonStyle(.freshnestPrimary)
                .padding(.horizontal, FreshnestSpacing.xxl)
                .accessibilityIdentifier("scan.confirmButton")

            Button("Choose another") { viewModel.showManualSelection() }
                .buttonStyle(.freshnestSecondary)
                .padding(.horizontal, FreshnestSpacing.xxl)
                .accessibilityIdentifier("scan.chooseAnotherButton")
            Spacer()
        }
        .padding()
    }

    private func addToKitchen(data: ScanResultData, image: UIImage?) {
        let batch = FoodBatch(
            foodDefinitionID: data.foodID,
            purchaseDate: container.clock.now,
            quantity: 1,
            unit: container.foodRepository.definition(for: data.foodID).defaultUnit,
            storageLocation: .counter,
            initialRipeness: .notSure,
            currentFreshnessScore: data.score
        )
        modelContext.insert(batch)
        let addedEvent = FoodEvent(batchID: batch.id, createdAt: container.clock.now, type: .added, quantity: 1)
        addedEvent.batch = batch
        modelContext.insert(addedEvent)
        attachScan(to: batch, data: data, image: image)
        viewModel?.reset()
        router.showFoodDetails(batchID: batch.id, from: .home)
    }

    private func updateExisting(batch: FoodBatch, data: ScanResultData, image: UIImage?) {
        batch.currentFreshnessScore = data.score
        batch.updatedAt = container.clock.now
        attachScan(to: batch, data: data, image: image)
        viewModel?.reset()
        router.showFoodDetails(batchID: batch.id, from: .home)
    }

    private func attachScan(to batch: FoodBatch, data: ScanResultData, image: UIImage?) {
        var storedPath: String?
        if container.settingsStore.storeScanPhotos, let image, let jpegData = ImageProcessing.jpegThumbnailData(from: image) {
            storedPath = try? container.scanPhotoStore.savePhoto(jpegData)
        }

        let scan = FreshnessScan(
            batchID: batch.id,
            createdAt: container.clock.now,
            detectedFoodID: data.foodID,
            foodConfidence: data.confidence,
            freshnessScore: data.score,
            freshnessState: data.state,
            freshnessConfidence: data.confidence,
            detectedIssues: data.observations,
            storedPhotoPath: storedPath
        )
        scan.batch = batch
        modelContext.insert(scan)
        let scannedEvent = FoodEvent(batchID: batch.id, createdAt: container.clock.now, type: .scanned)
        scannedEvent.batch = batch
        modelContext.insert(scannedEvent)
    }
}
