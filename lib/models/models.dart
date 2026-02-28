/// Data models mirroring the backend Pydantic schemas (v2).
library;

class AnalyzeRequest {
  final String businessType;
  final List<String> targetDemographic;
  final int budgetRange;

  const AnalyzeRequest({
    required this.businessType,
    required this.targetDemographic,
    required this.budgetRange,
  });

  Map<String, dynamic> toJson() => {
    'business_type': businessType,
    'target_demographic': targetDemographic,
    'budget_range': budgetRange,
  };
}

class ScoredArea {
  final String name;
  final double latitude;
  final double longitude;
  // Final & component scores
  final double score;
  final double demandScore;
  final double frictionScore;
  final double growthScore;
  final double clusteringBenefitFactor;
  // Raw indices (0-100)
  final double incomeIndex;
  final double footTrafficProxy;
  final double populationDensityIndex;
  final double competitionIndex;
  final double commercialRentIndex;
  final double accessibilityPenalty;
  final double areaGrowthTrend;
  final double vacancyRateImprovement;
  final double infrastructureInvestmentIndex;
  final List<String> reasoning;
  final int rank;

  const ScoredArea({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.score,
    required this.demandScore,
    required this.frictionScore,
    required this.growthScore,
    required this.clusteringBenefitFactor,
    required this.incomeIndex,
    required this.footTrafficProxy,
    required this.populationDensityIndex,
    required this.competitionIndex,
    required this.commercialRentIndex,
    required this.accessibilityPenalty,
    required this.areaGrowthTrend,
    required this.vacancyRateImprovement,
    required this.infrastructureInvestmentIndex,
    required this.reasoning,
    required this.rank,
  });

  factory ScoredArea.fromJson(Map<String, dynamic> json) => ScoredArea(
    name: json['name'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    score: (json['score'] as num).toDouble(),
    demandScore: (json['demand_score'] as num).toDouble(),
    frictionScore: (json['friction_score'] as num).toDouble(),
    growthScore: (json['growth_score'] as num).toDouble(),
    clusteringBenefitFactor: (json['clustering_benefit_factor'] as num)
        .toDouble(),
    incomeIndex: (json['income_index'] as num).toDouble(),
    footTrafficProxy: (json['foot_traffic_proxy'] as num).toDouble(),
    populationDensityIndex: (json['population_density_index'] as num)
        .toDouble(),
    competitionIndex: (json['competition_index'] as num).toDouble(),
    commercialRentIndex: (json['commercial_rent_index'] as num).toDouble(),
    accessibilityPenalty: (json['accessibility_penalty'] as num).toDouble(),
    areaGrowthTrend: (json['area_growth_trend'] as num).toDouble(),
    vacancyRateImprovement: (json['vacancy_rate_improvement'] as num)
        .toDouble(),
    infrastructureInvestmentIndex:
        (json['infrastructure_investment_index'] as num).toDouble(),
    reasoning: (json['reasoning'] as List).cast<String>(),
    rank: json['rank'] as int,
  );
}

class AnalyzeResponse {
  final List<ScoredArea> results;
  final String businessType;
  final int totalAreasAnalyzed;

  const AnalyzeResponse({
    required this.results,
    required this.businessType,
    required this.totalAreasAnalyzed,
  });

  factory AnalyzeResponse.fromJson(Map<String, dynamic> json) =>
      AnalyzeResponse(
        results: (json['results'] as List)
            .map((e) => ScoredArea.fromJson(e as Map<String, dynamic>))
            .toList(),
        businessType: json['business_type'] as String,
        totalAreasAnalyzed: json['total_areas_analyzed'] as int,
      );
}
