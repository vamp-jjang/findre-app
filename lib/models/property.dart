class Property {
  final String id;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final double price;
  final double squareFeet;
  final double acres;
  final String imageUrl;
  final bool isFavorite;
  final String listingCourtesy;

  Property({
    required this.id,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.price,
    required this.squareFeet,
    required this.acres,
    required this.imageUrl,
    this.isFavorite = false,
    required this.listingCourtesy,
  });

  Property copyWith({
    String? id,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    double? price,
    double? squareFeet,
    double? acres,
    String? imageUrl,
    bool? isFavorite,
    String? listingCourtesy,
  }) {
    return Property(
      id: id ?? this.id,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      price: price ?? this.price,
      squareFeet: squareFeet ?? this.squareFeet,
      acres: acres ?? this.acres,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      listingCourtesy: listingCourtesy ?? this.listingCourtesy,
    );
  }
}

// Mock data for property listings
List<Property> getMockProperties() {
  return [
    Property(
      id: '1',
      address: 'N/A 27th Street',
      city: 'Texas City',
      state: 'TX',
      zipCode: '77590',
      price: 175000,
      squareFeet: 108900,
      acres: 2.5,
      imageUrl: 'https://images.unsplash.com/photo-1628624747186-a941c476b7ef?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1740&q=80',
      listingCourtesy: 'Charna Graber Realty, 4097393611',
    ),
    Property(
      id: '2',
      address: '123 Main Street',
      city: 'Texas City',
      state: 'TX',
      zipCode: '77590',
      price: 299000,
      squareFeet: 2100,
      acres: 0.25,
      imageUrl: 'https://images.unsplash.com/photo-1592595896616-c37162298647?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1740&q=80',
      listingCourtesy: 'KW Horizons',
    ),
    Property(
      id: '3',
      address: '456 Oak Avenue',
      city: 'Texas City',
      state: 'TX',
      zipCode: '77591',
      price: 225000,
      squareFeet: 1800,
      acres: 0.18,
      imageUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1740&q=80',
      listingCourtesy: 'Local Realty Services',
    ),
    Property(
      id: '4',
      address: '789 Pine Lane',
      city: 'Texas City',
      state: 'TX',
      zipCode: '77590',
      price: 350000,
      squareFeet: 2500,
      acres: 0.3,
      imageUrl: 'https://images.unsplash.com/photo-1605276374104-dee2a0ed3cd6?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1740&q=80',
      listingCourtesy: 'KW Horizons',
    ),
    Property(
      id: '5',
      address: '101 Cedar Court',
      city: 'Texas City',
      state: 'TX',
      zipCode: '77591',
      price: 275000,
      squareFeet: 2000,
      acres: 0.22,
      imageUrl: 'https://images.unsplash.com/photo-1583608205776-bfd35f0d9f83?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1740&q=80',
      listingCourtesy: 'Charna Graber Realty, 4097393611',
    ),
  ];
}