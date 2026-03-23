/// Centralized mock data for client demo presentation.
/// All screens pull realistic data from here for a polished demo.
class MockData {
  MockData._();

  // ── User Profile ──
  static const userProfile = {
    'name': 'Rahul Sharma',
    'email': 'demo@RoAdRoBos.com',
    'phone': '+91 98765 43210',
    'avatar': 'https://i.pravatar.cc/150?img=12',
    'membershipTier': 'Gold',
    'loyaltyPoints': 1250,
    'totalRides': 42,
    'memberSince': 'Jan 2024',
  };

  // ── Service Items (10) ──
  static const List<Map<String, dynamic>> services = [
    {'id': 's1', 'title': 'General Service', 'desc': 'Complete car checkup with 40-point inspection', 'price': '₹2,499', 'rating': 4.8, 'image': 'https://images.unsplash.com/photo-1625047509248-ec889cbff17f?w=400', 'duration': '4-5 hrs', 'category': 'Maintenance'},
    {'id': 's2', 'title': 'Oil Change', 'desc': 'Full synthetic oil replacement with filter', 'price': '₹899', 'rating': 4.9, 'image': 'https://images.unsplash.com/photo-1487754180451-c456f719a1fc?w=400', 'duration': '1 hr', 'category': 'Maintenance'},
    {'id': 's3', 'title': 'Brake Pad Replacement', 'desc': 'OEM grade brake pads for all 4 wheels', 'price': '₹3,200', 'rating': 4.7, 'image': 'https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=400', 'duration': '2-3 hrs', 'category': 'Repair'},
    {'id': 's4', 'title': 'AC Gas Refill', 'desc': 'R134a refrigerant top-up with leak check', 'price': '₹1,799', 'rating': 4.6, 'image': 'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?w=400', 'duration': '1-2 hrs', 'category': 'AC & Climate'},
    {'id': 's5', 'title': 'Battery Replacement', 'desc': 'Amaron/Exide 12V battery with 2yr warranty', 'price': '₹4,500', 'rating': 4.8, 'image': 'https://images.unsplash.com/photo-1611348586804-61bf6c080437?w=400', 'duration': '30 min', 'category': 'Electrical'},
    {'id': 's6', 'title': 'Wheel Alignment', 'desc': 'Advanced 3D computerised alignment', 'price': '₹699', 'rating': 4.5, 'image': 'https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=400', 'duration': '45 min', 'category': 'Tyres'},
    {'id': 's7', 'title': 'Full Car Wash', 'desc': 'Premium foam wash, interior vacuum & dashboard polish', 'price': '₹599', 'rating': 4.9, 'image': 'https://images.unsplash.com/photo-1607860108855-64acf2078ed9?w=400', 'duration': '1 hr', 'category': 'Wash'},
    {'id': 's8', 'title': 'Clutch Plate Change', 'desc': 'Genuine clutch assembly with pressure plate', 'price': '₹7,999', 'rating': 4.7, 'image': 'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=400', 'duration': '5-6 hrs', 'category': 'Repair'},
    {'id': 's9', 'title': 'Ceramic Coating', 'desc': '9H nano ceramic coat — 3 year protection', 'price': '₹12,999', 'rating': 5.0, 'image': 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=400', 'duration': '2 days', 'category': 'Detailing'},
    {'id': 's10', 'title': 'Suspension Check', 'desc': 'Complete shock absorber and bushing inspection', 'price': '₹1,499', 'rating': 4.6, 'image': 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?w=400', 'duration': '2 hrs', 'category': 'Repair'},
  ];

  // ── Carousel Banners (3) ──
  static const List<Map<String, String>> banners = [
    {'title': 'Free AC Check-up', 'subtitle': 'Book any service & get AC inspection free', 'image': 'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?w=600', 'cta': 'Book Now'},
    {'title': '20% Off First Ride', 'subtitle': 'Use code FIRST20 on your maiden journey', 'image': 'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=600', 'cta': 'Claim Offer'},
    {'title': 'Gold Membership', 'subtitle': 'Unlock priority service & exclusive perks', 'image': 'https://images.unsplash.com/photo-1553440569-bcc63803a83d?w=600', 'cta': 'Upgrade'},
  ];

  // ── Categories (5) ──
  static const List<Map<String, String>> categories = [
    {'icon': 'build', 'label': 'Repair', 'count': '12'},
    {'icon': 'oil_barrel', 'label': 'Oil & Fluids', 'count': '6'},
    {'icon': 'ac_unit', 'label': 'AC & Climate', 'count': '5'},
    {'icon': 'tire_repair', 'label': 'Tyres', 'count': '10'},
    {'icon': 'car_wash', 'label': 'Wash & Clean', 'count': '8'},
  ];

  // ── Recent Bookings ──
  static const List<Map<String, String>> recentBookings = [
    {'service': 'General Service', 'vehicle': 'Hyundai Creta', 'status': 'Completed', 'date': '28 Feb 2026', 'price': '₹2,499'},
    {'service': 'Oil Change', 'vehicle': 'Honda City', 'status': 'In Progress', 'date': '07 Mar 2026', 'price': '₹899'},
    {'service': 'AC Service', 'vehicle': 'Hyundai Creta', 'status': 'Scheduled', 'date': '10 Mar 2026', 'price': '₹1,799'},
  ];

  // ── Vehicles ──
  static const List<Map<String, String>> vehicles = [
    {'name': 'Honda City', 'plate': 'MH 04 XY 4321', 'fuel': 'Petrol', 'year': '2022', 'type': 'Car'},
  ];

  // ── Rental Vehicles ──
  static const List<Map<String, dynamic>> rentalVehicles = [
    {
      'name': 'Maruti Baleno',
      'type': 'Hatchback',
      'price': '₹159/hr',
      'rating': '4.9',
      'seats': '5 Seats',
      'image': 'assets/icons/baleno.png',
      'category': 'Popular',
    },
    {
      'name': 'Honda City',
      'type': 'Sedan',
      'price': '₹179/hr',
      'rating': '4.9',
      'seats': '5 Seats',
      'image': 'assets/icons/city.png',
      'category': 'Luxury',
    },
    {
      'name': 'Maruti Swift',
      'type': 'Hatchback',
      'price': '₹129/hr',
      'rating': '4.8',
      'seats': '5 Seats',
      'image': 'assets/icons/swift.png',
      'category': 'Popular',
    },
    {
      'name': 'Mahindra Scorpio',
      'type': 'SUV',
      'price': '₹219/hr',
      'rating': '4.7',
      'seats': '7 Seats',
      'image': 'assets/icons/scorpio.png',
      'category': 'Popular',
    },
    {
      'name': 'Zelio Eeva E (Silver)',
      'type': 'EV Bike',
      'price': '₹45/hr',
      'rating': '4.8',
      'spec': 'Unlimited km',
      'image': 'assets/rentals/zeeoneevaesilver1.jpg',
      'category': 'EV',
      'isBike': true,
    },
    {
      'name': 'Zelio Eeva E (Red)',
      'type': 'EV Bike',
      'price': '₹45/hr',
      'rating': '4.7',
      'spec': 'Unlimited km',
      'image': 'assets/rentals/zeeoneevaered1.jpg',
      'category': 'EV',
      'isBike': true,
    },
    {
      'name': 'Zelio Eeva E (Blue)',
      'type': 'EV Bike',
      'price': '₹45/hr',
      'rating': '4.8',
      'spec': 'Unlimited km',
      'image': 'assets/rentals/zeeoneevaeblue1.jpg',
      'category': 'EV',
      'isBike': true,
    },
    {
      'name': 'Zelio Eeva E (White)',
      'type': 'EV Bike',
      'price': '₹45/hr',
      'rating': '4.9',
      'spec': 'Unlimited km',
      'image': 'assets/rentals/zeeoneevaewhite1.jpg',
      'category': 'EV',
      'isBike': true,
    },
    {
      'name': 'Zelio Eeva E (Black)',
      'type': 'EV Bike',
      'price': '₹45/hr',
      'rating': '4.8',
      'spec': 'Unlimited km',
      'image': 'assets/rentals/zeeoneevaeblack1.jpg',
      'category': 'EV',
      'isBike': true,
    },
    {
      'name': 'Honda Activa 6G',
      'type': 'Scooter',
      'price': '₹35/hr',
      'rating': '4.8',
      'spec': '110cc',
      'image': 'assets/rentals/hondaactiva1.png',
      'category': 'Bikes',
      'isBike': true,
    },
    {
      'name': 'Royal Enfield Classic',
      'type': 'Cruiser',
      'price': '₹95/hr',
      'rating': '4.9',
      'spec': '350cc',
      'image': 'assets/rentals/royalenfieldclassic1.png',
      'category': 'Bikes',
      'isBike': true,
    },
  ];
}
