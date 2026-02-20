/// Country-level metadata used by Edit Region to bind country to currency and seed city choices.
class CountryRegionMetadata {
  final String currencyCode;
  final String currencySymbol;
  final List<String> seedCities;

  const CountryRegionMetadata({
    required this.currencyCode,
    required this.currencySymbol,
    required this.seedCities,
  });
}

const Map<String, CountryRegionMetadata> kEuropeAfricaCountryMetadata = {
  'AL': CountryRegionMetadata(
    currencyCode: 'EUR',
    currencySymbol: "€",
    seedCities: ["Tirana"],
  ),
  'AD': CountryRegionMetadata(
    currencyCode: 'EUR',
    currencySymbol: "€",
    seedCities: ["Andorra la Vella"],
  ),
  'AM': CountryRegionMetadata(
    currencyCode: 'AMD',
    currencySymbol: "֏",
    seedCities: ["Yerevan"],
  ),
  'AT': CountryRegionMetadata(
    currencyCode: 'EUR',
    currencySymbol: "€",
    seedCities: ["Vienna"],
  ),
  'AZ': CountryRegionMetadata(
    currencyCode: 'AZN',
    currencySymbol: "₼",
    seedCities: ["Baku"],
  ),
  'BY': CountryRegionMetadata(
    currencyCode: 'BYN',
    currencySymbol: "Br",
    seedCities: ["Minsk"],
  ),
  'BE': CountryRegionMetadata(
    currencyCode: 'EUR',
    currencySymbol: "€",
    seedCities: ["Brussels"],
  ),
  'BA': CountryRegionMetadata(
    currencyCode: 'BAM',
    currencySymbol: "KM",
    seedCities: ["Sarajevo"],
  ),
  'BG': CountryRegionMetadata(
    currencyCode: 'BGN',
    currencySymbol: "лв",
    seedCities: ["Sofia"],
  ),
  'HR': CountryRegionMetadata(
    currencyCode: 'EUR',
    currencySymbol: "€",
    seedCities: ["Zagreb"],
  ),
  'CY': CountryRegionMetadata(
    currencyCode: 'EUR',
    currencySymbol: "€",
    seedCities: ["Nicosia"],
  ),
  'CZ': CountryRegionMetadata(
    currencyCode: 'CZK',
    currencySymbol: "Kč",
    seedCities: ["Prague"],
  ),
  'DK': CountryRegionMetadata(
    currencyCode: 'DKK',
    currencySymbol: "kr",
    seedCities: ["Copenhagen"],
  ),
  'EE': CountryRegionMetadata(
    currencyCode: 'EUR',
    currencySymbol: "€",
    seedCities: ["Tallinn"],
  ),
  'FI': CountryRegionMetadata(
    currencyCode: 'EUR',
    currencySymbol: "€",
    seedCities: ["Helsinki"],
  ),
  'FR': CountryRegionMetadata(
    currencyCode: 'EUR',
    currencySymbol: "€",
    seedCities: ["Paris"],
  ),
  'GE': CountryRegionMetadata(
    currencyCode: 'GEL',
    currencySymbol: "₾",
    seedCities: ["Tbilisi"],
  ),
  'DE': CountryRegionMetadata(
    currencyCode: 'EUR',
    currencySymbol: "€",
    seedCities: ["Berlin"],
  ),
  'GR': CountryRegionMetadata(
    currencyCode: 'EUR',
    currencySymbol: "€",
    seedCities: ["Athens"],
  ),
  'HU': CountryRegionMetadata(
    currencyCode: 'HUF',
    currencySymbol: "Ft",
    seedCities: ["Budapest"],
  ),
  'IS': CountryRegionMetadata(
    currencyCode: 'ISK',
    currencySymbol: "kr",
    seedCities: ["Reykjavik"],
  ),
  'IE': CountryRegionMetadata(
    currencyCode: 'EUR',
    currencySymbol: "€",
    seedCities: ["Dublin"],
  ),
  'IT': CountryRegionMetadata(
    currencyCode: 'EUR',
    currencySymbol: "€",
    seedCities: ["Rome"],
  ),
  'KZ': CountryRegionMetadata(
    currencyCode: 'KZT',
    currencySymbol: "₸",
    seedCities: ["Astana"],
  ),
  'XK': CountryRegionMetadata(
    currencyCode: 'EUR',
    currencySymbol: "€",
    seedCities: ["Pristina"],
  ),
  'LV': CountryRegionMetadata(
    currencyCode: 'EUR',
    currencySymbol: "€",
    seedCities: ["Riga"],
  ),
  'LI': CountryRegionMetadata(
    currencyCode: 'CHF',
    currencySymbol: "CHF",
    seedCities: ["Vaduz"],
  ),
  'LT': CountryRegionMetadata(
    currencyCode: 'EUR',
    currencySymbol: "€",
    seedCities: ["Vilnius"],
  ),
  'LU': CountryRegionMetadata(
    currencyCode: 'EUR',
    currencySymbol: "€",
    seedCities: ["Luxembourg"],
  ),
  'MT': CountryRegionMetadata(
    currencyCode: 'EUR',
    currencySymbol: "€",
    seedCities: ["Valletta"],
  ),
  'MD': CountryRegionMetadata(
    currencyCode: 'MDL',
    currencySymbol: "L",
    seedCities: ["Chișinău"],
  ),
  'MC': CountryRegionMetadata(
    currencyCode: 'EUR',
    currencySymbol: "€",
    seedCities: ["Monaco"],
  ),
  'ME': CountryRegionMetadata(
    currencyCode: 'EUR',
    currencySymbol: "€",
    seedCities: ["Podgorica"],
  ),
  'NL': CountryRegionMetadata(
    currencyCode: 'EUR',
    currencySymbol: "€",
    seedCities: ["Amsterdam"],
  ),
  'MK': CountryRegionMetadata(
    currencyCode: 'MKD',
    currencySymbol: "den",
    seedCities: ["Skopje"],
  ),
  'NO': CountryRegionMetadata(
    currencyCode: 'NOK',
    currencySymbol: "kr",
    seedCities: ["Oslo"],
  ),
  'PL': CountryRegionMetadata(
    currencyCode: 'PLN',
    currencySymbol: "zł",
    seedCities: ["Warsaw"],
  ),
  'PT': CountryRegionMetadata(
    currencyCode: 'EUR',
    currencySymbol: "€",
    seedCities: ["Lisbon"],
  ),
  'RO': CountryRegionMetadata(
    currencyCode: 'RON',
    currencySymbol: "lei",
    seedCities: ["Bucharest"],
  ),
  'RU': CountryRegionMetadata(
    currencyCode: 'RUB',
    currencySymbol: "₽",
    seedCities: ["Moscow"],
  ),
  'SM': CountryRegionMetadata(
    currencyCode: 'EUR',
    currencySymbol: "€",
    seedCities: ["City of San Marino"],
  ),
  'RS': CountryRegionMetadata(
    currencyCode: 'RSD',
    currencySymbol: "дин.",
    seedCities: ["Belgrade"],
  ),
  'SK': CountryRegionMetadata(
    currencyCode: 'EUR',
    currencySymbol: "€",
    seedCities: ["Bratislava"],
  ),
  'SI': CountryRegionMetadata(
    currencyCode: 'EUR',
    currencySymbol: "€",
    seedCities: ["Ljubljana"],
  ),
  'ES': CountryRegionMetadata(
    currencyCode: 'EUR',
    currencySymbol: "€",
    seedCities: ["Madrid"],
  ),
  'SE': CountryRegionMetadata(
    currencyCode: 'SEK',
    currencySymbol: "kr",
    seedCities: ["Stockholm"],
  ),
  'CH': CountryRegionMetadata(
    currencyCode: 'CHF',
    currencySymbol: "CHF",
    seedCities: ["Bern"],
  ),
  'TR': CountryRegionMetadata(
    currencyCode: 'TRY',
    currencySymbol: "₺",
    seedCities: ["Ankara"],
  ),
  'UA': CountryRegionMetadata(
    currencyCode: 'UAH',
    currencySymbol: "₴",
    seedCities: ["Kyiv"],
  ),
  'GB': CountryRegionMetadata(
    currencyCode: 'GBP',
    currencySymbol: "£",
    seedCities: ["London"],
  ),
  'VA': CountryRegionMetadata(
    currencyCode: 'EUR',
    currencySymbol: "€",
    seedCities: ["Vatican City"],
  ),
  'DZ': CountryRegionMetadata(
    currencyCode: 'DZD',
    currencySymbol: "DZD",
    seedCities: ["Algiers"],
  ),
  'AO': CountryRegionMetadata(
    currencyCode: 'AOA',
    currencySymbol: "Kz",
    seedCities: ["Luanda"],
  ),
  'BJ': CountryRegionMetadata(
    currencyCode: 'XOF',
    currencySymbol: "XOF",
    seedCities: ["Porto-Novo"],
  ),
  'BW': CountryRegionMetadata(
    currencyCode: 'BWP',
    currencySymbol: "P",
    seedCities: ["Gaborone"],
  ),
  'BF': CountryRegionMetadata(
    currencyCode: 'XOF',
    currencySymbol: "XOF",
    seedCities: ["Ouagadougou"],
  ),
  'BI': CountryRegionMetadata(
    currencyCode: 'BIF',
    currencySymbol: "Fr",
    seedCities: ["Gitega"],
  ),
  'CV': CountryRegionMetadata(
    currencyCode: 'CVE',
    currencySymbol: "Esc",
    seedCities: ["Praia"],
  ),
  'CM': CountryRegionMetadata(
    currencyCode: 'XAF',
    currencySymbol: "XAF",
    seedCities: ["Yaoundé"],
  ),
  'CF': CountryRegionMetadata(
    currencyCode: 'XAF',
    currencySymbol: "XAF",
    seedCities: ["Bangui"],
  ),
  'TD': CountryRegionMetadata(
    currencyCode: 'XAF',
    currencySymbol: "XAF",
    seedCities: ["N'Djamena"],
  ),
  'KM': CountryRegionMetadata(
    currencyCode: 'KMF',
    currencySymbol: "Fr",
    seedCities: ["Moroni"],
  ),
  'CG': CountryRegionMetadata(
    currencyCode: 'XAF',
    currencySymbol: "XAF",
    seedCities: ["Brazzaville"],
  ),
  'CD': CountryRegionMetadata(
    currencyCode: 'CDF',
    currencySymbol: "CDF",
    seedCities: ["Kinshasa"],
  ),
  'CI': CountryRegionMetadata(
    currencyCode: 'XOF',
    currencySymbol: "XOF",
    seedCities: ["Yamoussoukro"],
  ),
  'DJ': CountryRegionMetadata(
    currencyCode: 'DJF',
    currencySymbol: "Fr",
    seedCities: ["Djibouti"],
  ),
  'EG': CountryRegionMetadata(
    currencyCode: 'EGP',
    currencySymbol: "EGP",
    seedCities: ["Cairo"],
  ),
  'GQ': CountryRegionMetadata(
    currencyCode: 'XAF',
    currencySymbol: "XAF",
    seedCities: ["Malabo"],
  ),
  'ER': CountryRegionMetadata(
    currencyCode: 'ERN',
    currencySymbol: "Nfk",
    seedCities: ["Asmara"],
  ),
  'ET': CountryRegionMetadata(
    currencyCode: 'ETB',
    currencySymbol: "ETB",
    seedCities: ["Addis Ababa"],
  ),
  'GA': CountryRegionMetadata(
    currencyCode: 'XAF',
    currencySymbol: "XAF",
    seedCities: ["Libreville"],
  ),
  'GM': CountryRegionMetadata(
    currencyCode: 'GMD',
    currencySymbol: "D",
    seedCities: ["Banjul"],
  ),
  'GH': CountryRegionMetadata(
    currencyCode: 'GHS',
    currencySymbol: "₵",
    seedCities: ["Accra"],
  ),
  'GN': CountryRegionMetadata(
    currencyCode: 'GNF',
    currencySymbol: "Fr",
    seedCities: ["Conakry"],
  ),
  'GW': CountryRegionMetadata(
    currencyCode: 'XOF',
    currencySymbol: "XOF",
    seedCities: ["Bissau"],
  ),
  'KE': CountryRegionMetadata(
    currencyCode: 'KES',
    currencySymbol: "KES",
    seedCities: ["Nairobi"],
  ),
  'LS': CountryRegionMetadata(
    currencyCode: 'LSL',
    currencySymbol: "L",
    seedCities: ["Maseru"],
  ),
  'LR': CountryRegionMetadata(
    currencyCode: 'LRD',
    currencySymbol: "\$",
    seedCities: ["Monrovia"],
  ),
  'LY': CountryRegionMetadata(
    currencyCode: 'LYD',
    currencySymbol: "ل.د",
    seedCities: ["Tripoli"],
  ),
  'MG': CountryRegionMetadata(
    currencyCode: 'MGA',
    currencySymbol: "Ar",
    seedCities: ["Antananarivo"],
  ),
  'MW': CountryRegionMetadata(
    currencyCode: 'MWK',
    currencySymbol: "MK",
    seedCities: ["Lilongwe"],
  ),
  'ML': CountryRegionMetadata(
    currencyCode: 'XOF',
    currencySymbol: "XOF",
    seedCities: ["Bamako"],
  ),
  'MR': CountryRegionMetadata(
    currencyCode: 'MRU',
    currencySymbol: "UM",
    seedCities: ["Nouakchott"],
  ),
  'MU': CountryRegionMetadata(
    currencyCode: 'MUR',
    currencySymbol: "₨",
    seedCities: ["Port Louis"],
  ),
  'MA': CountryRegionMetadata(
    currencyCode: 'MAD',
    currencySymbol: "MAD",
    seedCities: ["Rabat"],
  ),
  'MZ': CountryRegionMetadata(
    currencyCode: 'MZN',
    currencySymbol: "MT",
    seedCities: ["Maputo"],
  ),
  'NA': CountryRegionMetadata(
    currencyCode: 'NAD',
    currencySymbol: "\$",
    seedCities: ["Windhoek"],
  ),
  'NE': CountryRegionMetadata(
    currencyCode: 'XOF',
    currencySymbol: "XOF",
    seedCities: ["Niamey"],
  ),
  'NG': CountryRegionMetadata(
    currencyCode: 'NGN',
    currencySymbol: "₦",
    seedCities: ["Abuja"],
  ),
  'RW': CountryRegionMetadata(
    currencyCode: 'RWF',
    currencySymbol: "Fr",
    seedCities: ["Kigali"],
  ),
  'ST': CountryRegionMetadata(
    currencyCode: 'STN',
    currencySymbol: "Db",
    seedCities: ["São Tomé"],
  ),
  'SN': CountryRegionMetadata(
    currencyCode: 'XOF',
    currencySymbol: "XOF",
    seedCities: ["Dakar"],
  ),
  'SC': CountryRegionMetadata(
    currencyCode: 'SCR',
    currencySymbol: "₨",
    seedCities: ["Victoria"],
  ),
  'SL': CountryRegionMetadata(
    currencyCode: 'SLL',
    currencySymbol: "Le",
    seedCities: ["Freetown"],
  ),
  'SO': CountryRegionMetadata(
    currencyCode: 'SOS',
    currencySymbol: "Sh",
    seedCities: ["Mogadishu"],
  ),
  'ZA': CountryRegionMetadata(
    currencyCode: 'ZAR',
    currencySymbol: "R",
    seedCities: ["Pretoria", "Bloemfontein", "Cape Town"],
  ),
  'SS': CountryRegionMetadata(
    currencyCode: 'SSP',
    currencySymbol: "£",
    seedCities: ["Juba"],
  ),
  'SD': CountryRegionMetadata(
    currencyCode: 'SDG',
    currencySymbol: "PT",
    seedCities: ["Khartoum"],
  ),
  'SZ': CountryRegionMetadata(
    currencyCode: 'SZL',
    currencySymbol: "L",
    seedCities: ["Lobamba"],
  ),
  'TZ': CountryRegionMetadata(
    currencyCode: 'TZS',
    currencySymbol: "TZS",
    seedCities: ["Dodoma"],
  ),
  'TG': CountryRegionMetadata(
    currencyCode: 'XOF',
    currencySymbol: "XOF",
    seedCities: ["Lomé"],
  ),
  'TN': CountryRegionMetadata(
    currencyCode: 'TND',
    currencySymbol: "د.ت",
    seedCities: ["Tunis"],
  ),
  'UG': CountryRegionMetadata(
    currencyCode: 'UGX',
    currencySymbol: "UGX",
    seedCities: ["Kampala"],
  ),
  'ZM': CountryRegionMetadata(
    currencyCode: 'ZMW',
    currencySymbol: "ZK",
    seedCities: ["Lusaka"],
  ),
  'ZW': CountryRegionMetadata(
    currencyCode: 'ZWL',
    currencySymbol: "Z\$",
    seedCities: ["Harare"],
  ),
};
