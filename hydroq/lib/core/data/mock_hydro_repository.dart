import 'dart:math';

import '../models/models.dart';

class MockHydroRepository {
  MockHydroRepository() : _random = Random(2407);

  final Random _random;
  int _tick = 0;

  final List<PlantProfile> plantProfiles = const <PlantProfile>[
    PlantProfile(
      id: 'lettuce',
      name: 'Selada',
      aliases: const <String>['lettuce'],
      category: 'Sayuran daun',
      difficulty: 'Pemula',
      phMin: 5.5,
      phMax: 6.5,
      ecMin: 1.2,
      ecMax: 1.8,
      daysToHarvest: 35,
      description: 'Selada tumbuh cepat, membutuhkan larutan yang sejuk, dan cocok untuk sistem NFT maupun rakit apung.',
      nutritionTips: <String>[
        'Pertahankan EC lebih rendah pada fase bibit.',
        'Naikkan nutrisi bertahap setelah akar terbentuk.',
      ],
      careTips: <String>[
        'Jaga suhu larutan sekitar 18–24°C.',
        'Berikan sirkulasi udara yang baik agar daun tidak lembap berlebihan.',
      ],
      commonProblems: <String>[
        'Daun pahit karena suhu terlalu tinggi.',
        'Ujung daun terbakar akibat EC berlebihan.',
      ],
      artSeed: 1,
    ),
    PlantProfile(
      id: 'pakcoy',
      name: 'Pakcoy',
      aliases: const <String>['pak choi', 'bok choy', 'sawi sendok'],
      category: 'Sayuran daun',
      difficulty: 'Pemula',
      phMin: 5.8,
      phMax: 6.5,
      ecMin: 1.5,
      ecMax: 2.0,
      daysToHarvest: 40,
      description: 'Pakcoy toleran terhadap berbagai sistem hidroponik dan ideal untuk pengguna yang baru memulai.',
      nutritionTips: <String>[
        'Gunakan nutrisi seimbang dengan nitrogen cukup.',
        'Periksa EC setelah penambahan air baru.',
      ],
      careTips: <String>[
        'Beri jarak antar tanaman untuk mencegah daun saling menutup.',
        'Pastikan akar tetap putih dan mendapat oksigen.',
      ],
      commonProblems: <String>[
        'Batang memanjang karena kurang cahaya.',
        'Daun menguning karena kekurangan nutrisi.',
      ],
      artSeed: 2,
    ),
    PlantProfile(
      id: 'water-spinach',
      name: 'Kangkung',
      aliases: const <String>['water spinach'],
      category: 'Sayuran daun',
      difficulty: 'Pemula',
      phMin: 5.5,
      phMax: 6.5,
      ecMin: 1.5,
      ecMax: 2.0,
      daysToHarvest: 28,
      description: 'Kangkung memiliki pertumbuhan cepat dan dapat dipanen berulang jika pangkal tanaman tetap sehat.',
      nutritionTips: <String>[
        'Jaga volume air stabil karena kangkung menyerap banyak air.',
        'Hindari EC terlalu rendah pada pertumbuhan vegetatif aktif.',
      ],
      careTips: <String>[
        'Pangkas di atas ruas untuk merangsang tunas baru.',
        'Bersihkan akar mati dari reservoir.',
      ],
      commonProblems: <String>[
        'Batang lunak akibat sirkulasi kurang.',
        'Pertumbuhan lambat saat cahaya tidak cukup.',
      ],
      artSeed: 3,
    ),
    PlantProfile(
      id: 'spinach',
      name: 'Bayam',
      aliases: const <String>['spinach'],
      category: 'Sayuran daun',
      difficulty: 'Pemula',
      phMin: 5.8,
      phMax: 6.5,
      ecMin: 1.8,
      ecMax: 2.3,
      daysToHarvest: 32,
      description: 'Bayam membutuhkan suplai nutrisi stabil dan pencahayaan cukup untuk menghasilkan daun lebar.',
      nutritionTips: <String>[
        'Pertahankan nitrogen yang cukup pada fase vegetatif.',
        'Tambahkan air sebelum larutan menjadi terlalu pekat.',
      ],
      careTips: <String>[
        'Jaga kanopi tetap terbuka untuk mengurangi jamur.',
        'Panen daun luar lebih dahulu.',
      ],
      commonProblems: <String>[
        'Daun pucat akibat pH terlalu tinggi.',
        'Pertumbuhan kerdil akibat akar kekurangan oksigen.',
      ],
      artSeed: 4,
    ),
    PlantProfile(
      id: 'tomato',
      name: 'Tomat',
      aliases: const <String>['tomato'],
      category: 'Tanaman buah',
      difficulty: 'Menengah',
      phMin: 5.5,
      phMax: 6.5,
      ecMin: 2.0,
      ecMax: 3.5,
      daysToHarvest: 85,
      description: 'Tomat memerlukan nutrisi lebih tinggi, penyangga tanaman, dan pemantauan konsisten saat berbunga dan berbuah.',
      nutritionTips: <String>[
        'Naikkan EC secara bertahap ketika tanaman mulai berbuah.',
        'Hindari perubahan pH mendadak yang dapat mengganggu penyerapan kalsium.',
      ],
      careTips: <String>[
        'Gunakan tali atau ajir sebagai penyangga.',
        'Lakukan penyerbukan ringan pada bunga.',
      ],
      commonProblems: <String>[
        'Blossom end rot akibat gangguan kalsium.',
        'Bunga rontok karena suhu tinggi.',
      ],
      artSeed: 5,
    ),
    PlantProfile(
      id: 'strawberry',
      name: 'Stroberi',
      aliases: const <String>['strawberry'],
      category: 'Tanaman buah',
      difficulty: 'Menengah',
      phMin: 5.5,
      phMax: 6.2,
      ecMin: 1.4,
      ecMax: 2.0,
      daysToHarvest: 95,
      description: 'Stroberi menyukai kondisi sejuk dan membutuhkan pengelolaan kelembapan yang rapi agar buah tidak mudah berjamur.',
      nutritionTips: <String>[
        'Gunakan EC sedang dan hindari larutan terlalu pekat.',
        'Pastikan kalium cukup saat pembentukan buah.',
      ],
      careTips: <String>[
        'Jaga mahkota tanaman tidak terendam.',
        'Buang daun tua dan buah rusak segera.',
      ],
      commonProblems: <String>[
        'Buah kecil akibat penyerbukan tidak merata.',
        'Jamur abu-abu pada lingkungan terlalu lembap.',
      ],
      artSeed: 6,
    ),
    PlantProfile(
      id: 'basil',
      name: 'Basil',
      aliases: const <String>['kemangi italia'],
      category: 'Herbal',
      difficulty: 'Pemula',
      phMin: 5.5,
      phMax: 6.5,
      ecMin: 1.0,
      ecMax: 1.6,
      daysToHarvest: 45,
      description: 'Basil mudah tumbuh, aromatik, dan cocok untuk dipanen berkala dengan pemangkasan rutin.',
      nutritionTips: <String>[
        'Gunakan EC ringan sampai sedang untuk rasa daun yang baik.',
        'Pantau volume karena daun lebat meningkatkan konsumsi air.',
      ],
      careTips: <String>[
        'Pangkas pucuk untuk merangsang percabangan.',
        'Buang bunga bila fokus utama adalah produksi daun.',
      ],
      commonProblems: <String>[
        'Daun menggulung saat suhu terlalu panas.',
        'Batang memanjang karena cahaya kurang.',
      ],
      artSeed: 7,
    ),
    PlantProfile(
      id: 'cucumber',
      name: 'Mentimun',
      aliases: const <String>['timun', 'cucumber'],
      category: 'Tanaman buah',
      difficulty: 'Menengah',
      phMin: 5.5,
      phMax: 6.5,
      ecMin: 1.7,
      ecMax: 2.5,
      daysToHarvest: 60,
      description: 'Mentimun tumbuh cepat, membutuhkan ruang rambat, dan mengonsumsi air dalam jumlah besar saat berbuah.',
      nutritionTips: <String>[
        'Pantau volume reservoir lebih sering saat tanaman berbuah.',
        'Pertahankan EC stabil untuk mencegah buah pahit atau bentuk tidak seragam.',
      ],
      careTips: <String>[
        'Sediakan trellis untuk rambatan.',
        'Pangkas daun tua di bagian bawah.',
      ],
      commonProblems: <String>[
        'Buah bengkok akibat penyerbukan atau nutrisi tidak stabil.',
        'Embun tepung pada sirkulasi udara buruk.',
      ],
      artSeed: 8,
    ),
  ];

  final List<AlertEvent> alertEvents = <AlertEvent>[
    AlertEvent(
      id: 'alert-1',
      title: 'EC mendekati batas atas',
      message: 'Nutrisi mendekati batas atas rentang ideal untuk Selada.',
      state: ReadingState.warning,
      createdAt: DateTime.now().subtract(const Duration(minutes: 18)),
      metric: 'EC',
      valueText: '1.78 mS/cm',
      durationMinutes: 4,
      targetRange: '1.2–1.8 mS/cm',
    ),
    AlertEvent(
      id: 'alert-2',
      title: 'Volume kembali stabil',
      message: 'Volume air kembali di atas batas minimum.',
      state: ReadingState.normal,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      metric: 'Volume',
      valueText: '42.5 L',
      targetRange: '≥ 18 L',
      endedAt: DateTime.now().subtract(const Duration(hours: 3)),
      resolved: true,
    ),
    AlertEvent(
      id: 'alert-3',
      title: 'pH terlalu rendah',
      message: 'pH berada di bawah batas aman selama 6 menit.',
      state: ReadingState.critical,
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      metric: 'pH',
      valueText: '5.2',
      durationMinutes: 6,
      targetRange: '5.5–6.5',
      endedAt: DateTime.now().subtract(const Duration(days: 1, hours: 1, minutes: 54)),
      resolved: true,
    ),
    AlertEvent(
      id: 'alert-4',
      title: 'Perangkat kembali online',
      message: 'HydroQ Hub telah tersambung kembali ke cloud.',
      state: ReadingState.normal,
      createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
      metric: 'Perangkat',
      valueText: 'Online',
      endedAt: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
      resolved: true,
    ),
  ];

  SensorSnapshot initialSnapshot() {
    final DateTime now = DateTime.now();
    return SensorSnapshot(
      ph: MetricReading(
        label: 'pH',
        value: 6.2,
        unit: '',
        minimum: 5.5,
        maximum: 6.5,
        state: ReadingState.normal,
        updatedAt: now,
      ),
      ec: MetricReading(
        label: 'Nutrisi',
        value: 1.78,
        unit: 'mS/cm',
        minimum: 1.2,
        maximum: 1.8,
        state: ReadingState.warning,
        updatedAt: now,
        secondaryValue: '1139 ppm',
      ),
      volume: MetricReading(
        label: 'Volume',
        value: 42.5,
        unit: 'L',
        minimum: 18,
        maximum: 60,
        state: ReadingState.normal,
        updatedAt: now,
      ),
      capacityLiters: 60,
      deviceOnline: true,
      updatedAt: now,
      overallState: ReadingState.warning,
    );
  }

  SensorSnapshot nextSnapshot(SensorSnapshot current) {
    _tick += 1;
    final DateTime now = DateTime.now();
    final double phValue = (6.18 + sin(_tick / 3) * 0.08 + (_random.nextDouble() - .5) * .02);
    final double ecValue = (1.78 + sin(_tick / 4) * 0.07 + (_random.nextDouble() - .5) * .02);
    final double volumeValue = max(39.5, (current.volume.value ?? 42.5) - 0.02);
    final MetricReading ph = MetricReading(
      label: 'pH',
      value: phValue,
      unit: '',
      minimum: current.ph.minimum,
      maximum: current.ph.maximum,
      state: classifyReading(
        value: phValue,
        minimum: current.ph.minimum,
        maximum: current.ph.maximum,
      ),
      updatedAt: now,
    );
    final MetricReading ec = MetricReading(
      label: 'Nutrisi',
      value: ecValue,
      unit: 'mS/cm',
      minimum: current.ec.minimum,
      maximum: current.ec.maximum,
      state: classifyReading(
        value: ecValue,
        minimum: current.ec.minimum,
        maximum: current.ec.maximum,
      ),
      updatedAt: now,
      secondaryValue: '${(ecValue * 640).round()} ppm',
    );
    final MetricReading volume = MetricReading(
      label: 'Volume',
      value: volumeValue,
      unit: 'L',
      minimum: current.volume.minimum,
      maximum: current.volume.maximum,
      state: classifyReading(
        value: volumeValue,
        minimum: current.volume.minimum,
        maximum: current.volume.maximum,
      ),
      updatedAt: now,
    );
    return SensorSnapshot(
      ph: ph,
      ec: ec,
      volume: volume,
      capacityLiters: current.capacityLiters,
      deviceOnline: true,
      updatedAt: now,
      overallState: combineReadingStates(
        <ReadingState>[ph.state, ec.state, volume.state],
      ),
    );
  }

  ReportSummary report(ReportMetric metric, ReportPeriod period) {
    final int count;
    switch (period) {
      case ReportPeriod.daily:
        count = 12;
        break;
      case ReportPeriod.weekly:
        count = 7;
        break;
      case ReportPeriod.monthly:
        count = 12;
        break;
    }
    final List<ChartPoint> points = List<ChartPoint>.generate(count, (int index) {
      final double value;
      switch (metric) {
        case ReportMetric.ph:
          value = 6.05 + sin(index / 1.6) * .18 + cos(index / 2.5) * .06;
          break;
        case ReportMetric.ec:
          value = 1.63 + sin(index / 1.8) * .2 + index * .012;
          break;
        case ReportMetric.volume:
          value = 53 - index * (period == ReportPeriod.monthly ? 1.2 : .72) + sin(index) * 1.4;
          break;
      }
      final String label;
      if (period == ReportPeriod.daily) {
        label = '${(index * 2).toString().padLeft(2, '0')}:00';
      } else if (period == ReportPeriod.weekly) {
        const List<String> days = <String>['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
        label = days[index];
      } else {
        label = 'M${index + 1}';
      }
      return ChartPoint(label, value);
    });
    final List<double> values = points.map((ChartPoint point) => point.value).toList();
    final double average = values.reduce((double a, double b) => a + b) / values.length;
    return ReportSummary(
      points: points,
      average: average,
      minimum: values.reduce(min),
      maximum: values.reduce(max),
      warningCount: metric == ReportMetric.ec ? 2 : 1,
      criticalCount: metric == ReportMetric.ph ? 1 : 0,
      abnormalDurationMinutes: metric == ReportMetric.ec ? 18 : metric == ReportMetric.ph ? 6 : 0,
    );
  }
}
