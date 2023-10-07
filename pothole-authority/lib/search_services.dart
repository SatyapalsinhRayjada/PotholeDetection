class SearchServices {
  final ahemdabadAreaToPincode = {
    "Vatva": "382440",
    "Bavla": "382220",
    "Tragad": "382470",
    "Nana Chiloda": "382330",
    "Navrangpura": "380009",
    "Sanand": "382110",
    "Mithapur": "382230",
    "Kuha": "382433",
    "Ambawadi": "380006",
    "Isanpur": "382443",
    "Godhavi": "382115",
    "Kanbha": "382430",
    "Ashram Road": "380009",
    "Devaliya": "382245",
    "Kathwada": "382430",
    "Jagatpur": "382470",
    "Vastral": "382418",
    "Kundli": "382245",
    "Sabarmati": "380005",
    "Ellisbridge": "380006",
    "gana": "388345",
    "vvnagar": "388120"
  };

  Map<String, String> getAreaToPincode(String searchQuery) {
    Map<String, String> areaToPincode = {};
    ahemdabadAreaToPincode.forEach((key, value) {
      if (key.toLowerCase().contains(searchQuery.toLowerCase())) {
        areaToPincode[key] = value;
      }
    });
    return areaToPincode;
  }
}
