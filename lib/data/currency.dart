class Currency {
  final String code;
  final String name;
  final String country;

  const Currency({
    required this.code,
    required this.name,
    required this.country,
  });
}

const List<Currency> currencies = [
  Currency(code: 'ARS', name: 'Argentine Peso', country: 'Argentina'),
  Currency(code: 'BRL', name: 'Brazilian Real', country: 'Brazil'),
  Currency(code: 'CLP', name: 'Chilean Peso', country: 'Chile'),
  Currency(code: 'COP', name: 'Colombian Peso', country: 'Colombia'),
  Currency(code: 'CRC', name: 'Costa Rican Colón', country: 'Costa Rica'),
  Currency(code: 'DOP', name: 'Dominican Peso', country: 'Dominican Republic'),
  Currency(code: 'EUR', name: 'Euro', country: 'European Union'),
  Currency(code: 'GTQ', name: 'Guatemalan Quetzal', country: 'Guatemala'),
  Currency(code: 'HNL', name: 'Honduran Lempira', country: 'Honduras'),
  Currency(code: 'MXN', name: 'Mexican Peso', country: 'Mexico'),
  Currency(code: 'PAB', name: 'Panamanian Balboa', country: 'Panama'),
  Currency(code: 'PEN', name: 'Peruvian Sol', country: 'Peru'),
  Currency(code: 'PYG', name: 'Paraguayan Guaraní', country: 'Paraguay'),
  Currency(code: 'UYU', name: 'Uruguayan Peso', country: 'Uruguay'),
  Currency(code: 'USD', name: 'US Dollar', country: 'United States'),
  Currency(code: 'VES', name: 'Venezuelan Bolívar', country: 'Venezuela'),
];
