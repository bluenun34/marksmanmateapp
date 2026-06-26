import '../models/paper_target_type.dart';

/// Reference paper targets with scoring-face dimensions for group analysis.
const paperTargetCatalog = <PaperTargetType>[
  // —— Air pistol ——
  PaperTargetType(
    id: 'air-pistol-issf-black',
    name: 'ISSF 10 m air pistol (black disk)',
    category: PaperTargetCategory.airPistol,
    faceDiameterMm: 59.5,
    bullDiameterMm: 11.5,
    ringDiametersMm: [59.5, 40.5, 27.5, 11.5],
    description: 'Standard 10 m air pistol — measure across the black circle.',
  ),
  PaperTargetType(
    id: 'air-pistol-card-155',
    name: 'ISSF 10 m air pistol card',
    category: PaperTargetCategory.airPistol,
    faceDiameterMm: 155,
    bullDiameterMm: 59.5,
    ringDiametersMm: [155, 59.5],
    description: 'Full 155 mm card — measure card width if square to frame.',
  ),
  PaperTargetType(
    id: 'air-pistol-bull-25',
    name: '25 mm practice bull',
    category: PaperTargetCategory.airPistol,
    faceDiameterMm: 25,
    bullDiameterMm: 8,
    description: 'Small practice bull often used on air pistol plates.',
  ),
  PaperTargetType(
    id: 'air-pistol-mtrfc-155',
    name: 'MRFC 155 mm air pistol',
    category: PaperTargetCategory.airPistol,
    faceDiameterMm: 155,
    description: 'Mid-range air pistol face used in some UK competitions.',
  ),

  // —— Air rifle / smallbore ——
  PaperTargetType(
    id: 'air-rifle-issf-10m',
    name: 'ISSF 10 m air rifle',
    category: PaperTargetCategory.airRifle,
    faceDiameterMm: 45.5,
    bullDiameterMm: 0.5,
    ringDiametersMm: [45.5, 39, 31, 23, 15, 7.5, 0.5],
    description: 'Complete 10 m air rifle target — 45.5 mm outer diameter.',
  ),
  PaperTargetType(
    id: 'air-rifle-15yd',
    name: '15 yard air rifle (NSRA)',
    category: PaperTargetCategory.airRifle,
    faceDiameterMm: 86,
    bullDiameterMm: 8,
    description: 'Typical 15 yd card — measure across the printed target face.',
  ),
  PaperTargetType(
    id: 'air-rifle-25yd',
    name: '25 yard smallbore rifle',
    category: PaperTargetCategory.airRifle,
    faceDiameterMm: 122,
    bullDiameterMm: 10,
    ringDiametersMm: [122, 80, 40, 10],
    description: 'Common 25 yd smallbore paper — ~4.8 in scoring face.',
  ),
  PaperTargetType(
    id: 'air-rifle-50m',
    name: '50 m smallbore rifle (metric)',
    category: PaperTargetCategory.airRifle,
    faceDiameterMm: 95,
    description: '50 m reduction of the 100 m smallbore target.',
  ),
  PaperTargetType(
    id: 'air-rifle-100m',
    name: '100 m smallbore rifle',
    category: PaperTargetCategory.airRifle,
    faceDiameterMm: 154.4,
    bullDiameterMm: 10.4,
    ringDiametersMm: [154.4, 112, 70, 28, 10.4],
    description: 'Full 100 m smallbore target outer diameter.',
  ),

  // —— Gallery & rimfire ——
  PaperTargetType(
    id: 'jack-pyke-140',
    name: 'Jack Pyke 140 mm (8-ring reactive)',
    category: PaperTargetCategory.gallery,
    faceDiameterMm: 99,
    bullDiameterMm: 6,
    ringDiametersMm: [99, 79, 62, 47, 33, 21, 12, 6],
    description:
        'Popular UK reactive target — orange shows through shot holes. '
        'Outer scoring circle ~99 mm on a 140 mm card.',
  ),
  PaperTargetType(
    id: 'gallery-50',
    name: '50 mm centre (gallery rifle)',
    category: PaperTargetCategory.gallery,
    faceDiameterMm: 50,
    bullDiameterMm: 15,
    description: 'Gallery rifle centre face — 50 mm diameter.',
  ),
  PaperTargetType(
    id: 'gallery-100',
    name: '100 mm black (gallery / practice)',
    category: PaperTargetCategory.gallery,
    faceDiameterMm: 100,
    bullDiameterMm: 25,
    ringDiametersMm: [100, 70, 40, 25],
    description: 'Popular 100 mm practice target face.',
  ),
  PaperTargetType(
    id: 'nsra-200',
    name: 'NSRA 200 mm multipurpose',
    category: PaperTargetCategory.gallery,
    faceDiameterMm: 200,
    bullDiameterMm: 50,
    ringDiametersMm: [200, 140, 80, 50],
    description: 'Widely used UK multipurpose 200 mm target.',
  ),
  PaperTargetType(
    id: 'nsra-250',
    name: 'NSRA 250 mm',
    category: PaperTargetCategory.gallery,
    faceDiameterMm: 250,
    description: 'Larger NSRA multipurpose face.',
  ),
  PaperTargetType(
    id: 'rimfire-50yd',
    name: '50 yard rimfire (200 mm face)',
    category: PaperTargetCategory.gallery,
    faceDiameterMm: 200,
    description: 'Typical 50 yd rimfire paper target face.',
  ),

  // —— Full-bore & F-Class ——
  PaperTargetType(
    id: 'fullbore-300m',
    name: '300 m centre-fire (500 mm face)',
    category: PaperTargetCategory.fullBore,
    faceDiameterMm: 500,
    description: 'Metric 300 m target — measure full face diameter on photo.',
  ),
  PaperTargetType(
    id: 'fullbore-600yd-mrfc',
    name: '600 yard MRFC (black 20 in)',
    category: PaperTargetCategory.fullBore,
    faceDiameterMm: 508,
    description: '600 yd aiming mark — 20 inch black diameter.',
  ),
  PaperTargetType(
    id: 'fullbore-550',
    name: '550 mm full face (1000 yd type)',
    category: PaperTargetCategory.fullBore,
    faceDiameterMm: 550,
    description: 'Large full-bore face used at long range.',
  ),
  PaperTargetType(
    id: 'fullbore-812',
    name: '600 yard F-Class (32 in outer)',
    category: PaperTargetCategory.fullBore,
    faceDiameterMm: 812.8,
    description: 'F-Class 600 yd target outer diameter (32 in).',
  ),
  PaperTargetType(
    id: 'fullbore-1000yd',
    name: '1000 yard F-Class face',
    category: PaperTargetCategory.fullBore,
    faceDiameterMm: 914.4,
    description: '1000 yd F-Class — 36 in outer ring (approx.).',
  ),

  // —— HFT & field target ——
  PaperTargetType(
    id: 'hft-kz-25',
    name: 'HFT 25 mm kill zone',
    category: PaperTargetCategory.hftFt,
    faceDiameterMm: 25,
    description: 'Hunter Field Target — 25 mm kill zone plate.',
  ),
  PaperTargetType(
    id: 'hft-kz-35',
    name: 'HFT 35 mm kill zone',
    category: PaperTargetCategory.hftFt,
    faceDiameterMm: 35,
    description: 'Hunter Field Target — 35 mm kill zone.',
  ),
  PaperTargetType(
    id: 'hft-kz-40',
    name: 'HFT 40 mm kill zone',
    category: PaperTargetCategory.hftFt,
    faceDiameterMm: 40,
    description: 'Common HFT kill zone size.',
  ),
  PaperTargetType(
    id: 'ft-kz-40',
    name: 'Field target 40 mm kill zone',
    category: PaperTargetCategory.hftFt,
    faceDiameterMm: 40,
    description: 'WFTF-style 40 mm kill zone face.',
  ),
  PaperTargetType(
    id: 'ft-kz-45',
    name: 'Field target 45 mm kill zone',
    category: PaperTargetCategory.hftFt,
    faceDiameterMm: 45,
    description: 'Larger field-target kill zone.',
  ),

  // —— Other ——
  PaperTargetType(
    id: 'other-152',
    name: 'IPSC metric target (152 mm wide)',
    category: PaperTargetCategory.other,
    faceDiameterMm: 152,
    description: 'Metric IPSC target body width for approximate scale.',
  ),
  PaperTargetType(
    id: 'other-100-round',
    name: '100 mm round practice face',
    category: PaperTargetCategory.other,
    faceDiameterMm: 100,
    description: 'Generic 100 mm round paper target.',
  ),
];

PaperTargetType? paperTargetById(String id) {
  for (final target in paperTargetCatalog) {
    if (target.id == id) return target;
  }
  return null;
}

PaperTargetType get defaultPaperTarget =>
    paperTargetById('nsra-200') ?? paperTargetCatalog.first;
