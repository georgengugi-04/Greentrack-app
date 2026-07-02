// GreenTrack core domain models
// Covers: Users (Farmer/Chef/Consumer), CropBatch, TransportRecord, Meal,
// NutritionReference, MealNutritionSnapshot, Allergen, MealAllergen,
// QRCode, Notifications.
//
// These are plain Dart model classes (fromJson/toJson included) so they map
// cleanly onto Firestore documents later. MockData at the bottom seeds a
// realistic, interconnected dataset for screen-building before real
// persistence is wired in via Riverpod providers.

import 'package:flutter/foundation.dart';

// ---------------------------------------------------------------------------
// ENUMS
// ---------------------------------------------------------------------------

enum UserRole { farmer, chef, consumer }

enum CropStage {
  planned,
  planted,
  sprouting,
  vegetative,
  flowering,
  fruiting,
  readyToHarvest,
  harvested,
  concern,
  failed,
}

enum FarmingMethod { organic, conventional, hydroponic, permaculture, agroforestry }

enum SunExposure { fullSun, partialSun, shade }

enum IrrigationSource { rain, borehole, municipal, river, storedTank }

enum PestSeverity { low, moderate, severe }

enum HarvestDestination { consumed, sold, donated, stored, composted }

enum TransportMode { road, rail, air, sea }

enum NotificationType {
  phiCountdown,
  harvestReminder,
  buyerAvailability,
  chefInventoryAlert,
  scanConfirmation,
  general,
}

// 14 EU/UK recognized major allergens, plus "none".
enum AllergenType {
  gluten,
  milk,
  eggs,
  peanuts,
  treeNuts,
  soybeans,
  fish,
  crustaceans,
  molluscs,
  sesame,
  mustard,
  celery,
  lupin,
  sulphites,
  none,
}

extension AllergenTypeLabel on AllergenType {
  String get label {
    switch (this) {
      case AllergenType.gluten:
        return 'Cereals containing gluten';
      case AllergenType.milk:
        return 'Milk (Dairy)';
      case AllergenType.eggs:
        return 'Eggs';
      case AllergenType.peanuts:
        return 'Peanuts';
      case AllergenType.treeNuts:
        return 'Tree nuts';
      case AllergenType.soybeans:
        return 'Soybeans (Soy)';
      case AllergenType.fish:
        return 'Fish';
      case AllergenType.crustaceans:
        return 'Crustaceans';
      case AllergenType.molluscs:
        return 'Molluscs';
      case AllergenType.sesame:
        return 'Sesame';
      case AllergenType.mustard:
        return 'Mustard';
      case AllergenType.celery:
        return 'Celery';
      case AllergenType.lupin:
        return 'Lupin';
      case AllergenType.sulphites:
        return 'Sulphites/Sulfur dioxide';
      case AllergenType.none:
        return 'None';
    }
  }
}

// ---------------------------------------------------------------------------
// USER
// ---------------------------------------------------------------------------

@immutable
class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? photoUrl;
  // Role-specific extras
  final String? farmName; // farmer
  final String? restaurantName; // chef
  final String? organicCertificationUrl; // farmer

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl,
    this.farmName,
    this.restaurantName,
    this.organicCertificationUrl,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        role: UserRole.values.byName(json['role'] as String),
        photoUrl: json['photoUrl'] as String?,
        farmName: json['farmName'] as String?,
        restaurantName: json['restaurantName'] as String?,
        organicCertificationUrl: json['organicCertificationUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role.name,
        'photoUrl': photoUrl,
        'farmName': farmName,
        'restaurantName': restaurantName,
        'organicCertificationUrl': organicCertificationUrl,
      };
}

// ---------------------------------------------------------------------------
// CROP BATCH  (Plan -> Plant -> Nurture -> Track -> Harvest)
// ---------------------------------------------------------------------------

class GeoPoint {
  final double lat;
  final double lng;
  const GeoPoint(this.lat, this.lng);

  factory GeoPoint.fromJson(Map<String, dynamic> json) =>
      GeoPoint((json['lat'] as num).toDouble(), (json['lng'] as num).toDouble());
  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};
}

class IrrigationLog {
  final String id;
  final DateTime timestamp;
  final IrrigationSource source;
  final double liters;
  final String? notes;

  IrrigationLog({
    required this.id,
    required this.timestamp,
    required this.source,
    required this.liters,
    this.notes,
  });
}

class PestDiagnosis {
  final String id;
  final DateTime timestamp;
  final String photoUrl;
  final String detectedPest;
  final PestSeverity severity;
  final String recommendedPesticide;
  final String applicationInstructions;
  final int phiDays; // pre-harvest interval triggered by this treatment
  final DateTime? treatedAt;

  PestDiagnosis({
    required this.id,
    required this.timestamp,
    required this.photoUrl,
    required this.detectedPest,
    required this.severity,
    required this.recommendedPesticide,
    required this.applicationInstructions,
    required this.phiDays,
    this.treatedAt,
  });

  /// Date after which harvest is safe, or null if untreated.
  DateTime? get phiClearDate =>
      treatedAt?.add(Duration(days: phiDays));

  bool get isHarvestLocked =>
      phiClearDate != null && DateTime.now().isBefore(phiClearDate!);
}

class CropBatch {
  final String id;
  final String farmerId;
  final String cropName;
  final FarmingMethod farmingMethod;
  final GeoPoint plotLocation;
  final String? plotName;
  final SunExposure sunExposure;
  final CropStage stage;
  final DateTime plannedDate;
  final DateTime? plantedDate;
  final List<IrrigationLog> irrigationLogs;
  final List<PestDiagnosis> pestDiagnoses;
  final double? estimatedYieldKg;
  final DateTime? estimatedHarvestDate;
  final double? verifiedWeightKg;
  final DateTime? harvestedAt;
  final String? harvestWeatherConditions;
  final bool organicCertified;
  final String? organicCertificationUrl;
  final String? qrCodeId;

  CropBatch({
    required this.id,
    required this.farmerId,
    required this.cropName,
    required this.farmingMethod,
    required this.plotLocation,
    this.plotName,
    required this.sunExposure,
    required this.stage,
    required this.plannedDate,
    this.plantedDate,
    this.irrigationLogs = const [],
    this.pestDiagnoses = const [],
    this.estimatedYieldKg,
    this.estimatedHarvestDate,
    this.verifiedWeightKg,
    this.harvestedAt,
    this.harvestWeatherConditions,
    this.organicCertified = false,
    this.organicCertificationUrl,
    this.qrCodeId,
  });

  /// True if any active pest treatment is still within its PHI window.
  bool get harvestLockedByPHI =>
      pestDiagnoses.any((p) => p.isHarvestLocked);

  DateTime? get earliestPHIClearDate {
    final dates = pestDiagnoses
        .map((p) => p.phiClearDate)
        .whereType<DateTime>()
        .toList();
    if (dates.isEmpty) return null;
    dates.sort();
    return dates.last;
  }
}

// ---------------------------------------------------------------------------
// TRANSPORT
// ---------------------------------------------------------------------------

class TransportRecord {
  final String id;
  final String cropBatchId;
  final TransportMode mode;
  final String originLabel;
  final String destinationLabel;
  final DateTime departedAt;
  final DateTime? arrivedAt;
  final String? carrierName;
  final bool autoLogged;

  TransportRecord({
    required this.id,
    required this.cropBatchId,
    required this.mode,
    required this.originLabel,
    required this.destinationLabel,
    required this.departedAt,
    this.arrivedAt,
    this.carrierName,
    this.autoLogged = true,
  });

  Duration? get transitDuration =>
      arrivedAt?.difference(departedAt);
}

// ---------------------------------------------------------------------------
// NUTRITION
// ---------------------------------------------------------------------------

/// Per-100g nutrient density reference, keyed by crop name. Seeds the
/// system-calculated nutrition for meals built from verified batches.
class NutritionReference {
  final String cropName;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double fiberPer100g;

  const NutritionReference({
    required this.cropName,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    required this.fiberPer100g,
  });
}

class MealIngredient {
  final String cropBatchId;
  final String cropName;
  final double quantityGrams;
  MealIngredient({
    required this.cropBatchId,
    required this.cropName,
    required this.quantityGrams,
  });
}

/// Computed nutrition for a Meal — derived automatically from
/// NutritionReference x ingredient quantities, never entered manually.
class MealNutritionSnapshot {
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fiberG;

  const MealNutritionSnapshot({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.fiberG,
  });

  static MealNutritionSnapshot calculate(
    List<MealIngredient> ingredients,
    Map<String, NutritionReference> referenceByCrop,
  ) {
    double cal = 0, protein = 0, carbs = 0, fat = 0, fiber = 0;
    for (final ing in ingredients) {
      final ref = referenceByCrop[ing.cropName];
      if (ref == null) continue;
      final factor = ing.quantityGrams / 100.0;
      cal += ref.caloriesPer100g * factor;
      protein += ref.proteinPer100g * factor;
      carbs += ref.carbsPer100g * factor;
      fat += ref.fatPer100g * factor;
      fiber += ref.fiberPer100g * factor;
    }
    return MealNutritionSnapshot(
      calories: cal,
      proteinG: protein,
      carbsG: carbs,
      fatG: fat,
      fiberG: fiber,
    );
  }
}

// ---------------------------------------------------------------------------
// ALLERGENS  (normalized: Allergen reference + MealAllergen join)
// ---------------------------------------------------------------------------

class Allergen {
  final AllergenType type;
  const Allergen(this.type);
  String get label => type.label;
}

class MealAllergen {
  final String mealId;
  final AllergenType allergenId;
  final bool contains;
  final bool mayContain;
  final String? notes;

  MealAllergen({
    required this.mealId,
    required this.allergenId,
    this.contains = false,
    this.mayContain = false,
    this.notes,
  });
}

// ---------------------------------------------------------------------------
// MEAL  (Chef module)
// ---------------------------------------------------------------------------

class Meal {
  final String id;
  final String chefId;
  final String restaurantName;
  final String name;
  final List<MealIngredient> ingredients;
  final MealNutritionSnapshot nutrition;
  final List<MealAllergen> allergens;
  final String? otherAllergenNote;
  final DateTime createdAt;
  final String? qrCodeId;

  Meal({
    required this.id,
    required this.chefId,
    required this.restaurantName,
    required this.name,
    required this.ingredients,
    required this.nutrition,
    required this.allergens,
    this.otherAllergenNote,
    required this.createdAt,
    this.qrCodeId,
  });
}

// ---------------------------------------------------------------------------
// QR CODE  (shared resolver target for CropBatch or Meal)
// ---------------------------------------------------------------------------

enum QRTargetType { cropBatch, meal }

class QRCodeRecord {
  final String id; // encoded into the QR image itself
  final QRTargetType targetType;
  final String targetId; // cropBatchId or mealId
  final DateTime generatedAt;

  QRCodeRecord({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.generatedAt,
  });
}

// ---------------------------------------------------------------------------
// NOTIFICATIONS
// ---------------------------------------------------------------------------

class AppNotification {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;
  final String? relatedEntityId;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.read = false,
    this.relatedEntityId,
  });
}

// ---------------------------------------------------------------------------
// MOCK DATA  (stand-in repository until Riverpod + Firestore wiring)
// ---------------------------------------------------------------------------

class MockData {
  MockData._();

  static final List<AppUser> users = [
    const AppUser(
      id: 'u_mwangi',
      name: 'Mwangi',
      email: 'mwangi@greentrack.app',
      role: UserRole.farmer,
      farmName: "Mwangi's Garden",
    ),
    const AppUser(
      id: 'u_sarah',
      name: 'Sarah',
      email: 'sarah@greentrack.app',
      role: UserRole.chef,
      restaurantName: 'Fresh Bite Restaurant',
    ),
    const AppUser(
      id: 'u_mary',
      name: 'Mary',
      email: 'mary@greentrack.app',
      role: UserRole.consumer,
    ),
    const AppUser(
      id: 'u_faith',
      name: 'Faith',
      email: 'faith@greentrack.app',
      role: UserRole.consumer,
    ),
  ];

  static final Map<String, NutritionReference> nutritionReference = {
    'Tomatoes': const NutritionReference(
      cropName: 'Tomatoes',
      caloriesPer100g: 18,
      proteinPer100g: 0.9,
      carbsPer100g: 3.9,
      fatPer100g: 0.2,
      fiberPer100g: 1.2,
    ),
    'Lettuce': const NutritionReference(
      cropName: 'Lettuce',
      caloriesPer100g: 15,
      proteinPer100g: 1.4,
      carbsPer100g: 2.9,
      fatPer100g: 0.2,
      fiberPer100g: 1.3,
    ),
    'Carrots': const NutritionReference(
      cropName: 'Carrots',
      caloriesPer100g: 41,
      proteinPer100g: 0.9,
      carbsPer100g: 9.6,
      fatPer100g: 0.2,
      fiberPer100g: 2.8,
    ),
    'Avocado': const NutritionReference(
      cropName: 'Avocado',
      caloriesPer100g: 160,
      proteinPer100g: 2.0,
      carbsPer100g: 8.5,
      fatPer100g: 14.7,
      fiberPer100g: 6.7,
    ),
  };

  static final CropBatch sampleBatch = CropBatch(
    id: 'batch_001',
    farmerId: 'u_mwangi',
    cropName: 'Tomatoes',
    farmingMethod: FarmingMethod.organic,
    plotLocation: const GeoPoint(-1.286389, 36.817223),
    plotName: 'Plot A',
    sunExposure: SunExposure.fullSun,
    stage: CropStage.harvested,
    plannedDate: DateTime(2026, 4, 1),
    plantedDate: DateTime(2026, 4, 5),
    verifiedWeightKg: 48.5,
    harvestedAt: DateTime(2026, 6, 20, 7, 30),
    harvestWeatherConditions: 'Clear, 24°C',
    organicCertified: true,
    qrCodeId: 'qr_batch_001',
  );

  static final List<MealIngredient> sampleMealIngredients = [
    MealIngredient(cropBatchId: 'batch_001', cropName: 'Tomatoes', quantityGrams: 80),
    MealIngredient(cropBatchId: 'batch_002', cropName: 'Lettuce', quantityGrams: 60),
    MealIngredient(cropBatchId: 'batch_003', cropName: 'Carrots', quantityGrams: 50),
    MealIngredient(cropBatchId: 'batch_004', cropName: 'Avocado', quantityGrams: 40),
  ];

  static final Meal sampleMeal = Meal(
    id: 'meal_001',
    chefId: 'u_sarah',
    restaurantName: 'Fresh Bite Restaurant',
    name: 'Grilled Vegetable Salad',
    ingredients: sampleMealIngredients,
    nutrition: MealNutritionSnapshot.calculate(
      sampleMealIngredients,
      nutritionReference,
    ),
    allergens: [
      MealAllergen(mealId: 'meal_001', allergenId: AllergenType.milk, contains: true),
      MealAllergen(mealId: 'meal_001', allergenId: AllergenType.sesame, contains: true),
      MealAllergen(
        mealId: 'meal_001',
        allergenId: AllergenType.treeNuts,
        mayContain: true,
      ),
    ],
    createdAt: DateTime(2026, 6, 28, 11, 0),
    qrCodeId: 'qr_meal_001',
  );
}
