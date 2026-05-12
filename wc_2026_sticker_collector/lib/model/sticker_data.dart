// Class holding data about existing sticker groups, and mappings for flags and translation to portuguese
import 'package:circle_flags/circle_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class StickerData {
  static Widget getFlagAvatar(String countryCode, {double size = 24}) {
    bool hasFlag = paniniToIso.containsKey(countryCode);

    // manually check for England
    if (countryCode == 'ENG') {
      return SvgPicture.asset('assets/images/gb-eng.svg', width: size, height: size, fit: BoxFit.contain);
    }
    
    // manually check for Scotland
    if (countryCode == 'SCO') {
      return SvgPicture.asset('assets/images/gb-sct.svg', width: size, height: size, fit: BoxFit.contain);
    }

    if (countryCode == "00") {
      return Image(image: AssetImage("assets/images/Logo_caxoro.png"), width: size, height: size, fit: BoxFit.contain);
    }
    
    if (countryCode == "FWC") {
      return SvgPicture.asset('assets/images/2026_FIFA_World_Cup_emblem.svg', width: size, height: size, fit: BoxFit.contain);
    }

    // custom Coca-Cola image (to not infringe any copyright)
    if (countryCode == 'CC') {
      return SizedBox(
        width: size, 
        height: size, 
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF40009), 
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            "CC", 
            style: TextStyle(
              color: Colors.white, 
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              fontSize: size*0.4
            ),
          ),
        ),
      );
    }

    // use package for remaining countries
    if (hasFlag) {
      return CircleFlag(paniniToIso[countryCode]!, size: size);
    }
    
    // for others
    return Icon(Icons.star, size: (size-4), color: Colors.amber);
  }

  static const Map<String, List<String>> groups = {
    "Group A": ["MEX","RSA","KOR","CZE"],
    "Group B": ["CAN","BIH","QAT","SUI"],
    "Group C": ["BRA","MAR","HAI","SCO"],
    "Group D": ["USA","PAR","AUS","TUR"],
    "Group E": ["GER","CUW","CIV","ECU"],
    "Group F": ["NED","JPN","SWE","TUN"],
    "Group G": ["BEL","EGY","IRN","NZL"],
    "Group H": ["ESP","CPV","KSA","URU"],
    "Group I": ["FRA","SEN","IRQ","NOR"],
    "Group J": ["ARG","ALG","AUT","JOR"],
    "Group K": ["POR","COD","UZB","COL"],
    "Group L": ["ENG","CRO","GHA","PAN"],
    "Others":  ["00", "FWC", "CC"]
  };

  static const Map<String, String> paniniToIso = {
    // Group A
    "MEX": "mx", // Mexico
    "RSA": "za", // South Africa
    "KOR": "kr", // South Korea
    "CZE": "cz", // Czech Republic

    // Group B
    "CAN": "ca", // Canada
    "BIH": "ba", // Bosnia and Herzegovina
    "QAT": "qa", // Qatar
    "SUI": "ch", // Switzerland

    // Group C
    "BRA": "br", // Brazil
    "MAR": "ma", // Morocco
    "HAI": "ht", // Haiti
    "SCO": "gb-sct", // Scotland (Special sub-national code)

    // Group D
    "USA": "us", // United States
    "PAR": "py", // Paraguay
    "AUS": "au", // Australia
    "TUR": "tr", // Turkey

    // Group E
    "GER": "de", // Germany
    "CUW": "cw", // Curaçao
    "CIV": "ci", // Côte d'Ivoire (Ivory Coast)
    "ECU": "ec", // Ecuador

    // Group F
    "NED": "nl", // Netherlands
    "JPN": "jp", // Japan
    "SWE": "se", // Sweden
    "TUN": "tn", // Tunisia

    // Group G
    "BEL": "be", // Belgium
    "EGY": "eg", // Egypt
    "IRN": "ir", // Iran
    "NZL": "nz", // New Zealand

    // Group H
    "ESP": "es", // Spain
    "CPV": "cv", // Cape Verde
    "KSA": "sa", // Saudi Arabia
    "URU": "uy", // Uruguay

    // Group I
    "FRA": "fr", // France
    "SEN": "sn", // Senegal
    "IRQ": "iq", // Iraq
    "NOR": "no", // Norway

    // Group J
    "ARG": "ar", // Argentina
    "ALG": "dz", // Algeria
    "AUT": "at", // Austria
    "JOR": "jo", // Jordan

    // Group K
    "POR": "pt", // Portugal
    "COD": "cd", // DR Congo
    "UZB": "uz", // Uzbekistan
    "COL": "co", // Colombia

    // Group L
    "ENG": "gb-eng", // England (Special sub-national code)
    "CRO": "hr", // Croatia
    "GHA": "gh", // Ghana
    "PAN": "pa", // Panama
  };

  static const Map<String, String> paniniToName = {
    // Group A
    "MEX": "México", 
    "RSA": "África do Sul",
    "KOR": "Coreia do Sul", 
    "CZE": "Chéquia",

    // Group B
    "CAN": "Canadá",
    "BIH": "Bósnia e Herzegovina",
    "QAT": "Catar",
    "SUI": "Suíça",

    // Group C
    "BRA": "Brasil",
    "MAR": "Marrocos",
    "HAI": "Haiti",
    "SCO": "Escócia",

    // Group D
    "USA": "Estados Unidos",
    "PAR": "Paraguai",
    "AUS": "Austrália",
    "TUR": "Turquia",

    // Group E
    "GER": "Alemanha",
    "CUW": "Curaçau",
    "CIV": "Costa do Marfim",
    "ECU": "Equador",

    // Group F
    "NED": "Países Baixos",
    "JPN": "Japão",
    "SWE": "Suécia",
    "TUN": "Tunísia",

    // Group G
    "BEL": "Bélgica",
    "EGY": "Egito",
    "IRN": "Irão",
    "NZL": "Nova Zelândia",

    // Group H
    "ESP": "Espanha",
    "CPV": "Cabo Verde",
    "KSA": "Arábia Saudita",
    "URU": "Uruguai",

    // Group I
    "FRA": "França",
    "SEN": "Senegal",
    "IRQ": "Iraque",
    "NOR": "Noruega",

    // Group J
    "ARG": "Argentina",
    "ALG": "Argélia",
    "AUT": "Áustria",
    "JOR": "Jordânia",

    // Group K
    "POR": "Portugal",
    "COD": "RD Congo",
    "UZB": "Uzbequistão",
    "COL": "Colômbia",

    // Group L
    "ENG": "Inglaterra",
    "CRO": "Croácia",
    "GHA": "Gana",
    "PAN": "Panamá",
    
    // Others
    "00": "Especial",
    "FWC": "FIFA World Cup",
    "CC": "Coca-Cola",
  };

  // A map of 3-letter country codes to their iconic national kit/flag colors
  static const Map<String, Color> countryColors = {
    // South America (CONMEBOL)
    'ARG': Color(0xFF43A1D5), // Argentina Light Blue
    'BRA': Color(0xFFFFDC02), // Brazil Yellow
    'URU': Color(0xFF5CB8E4), // Uruguay Blue
    'ECU': Color(0xFFFFDD00), // Ecuador Yellow
    'COL': Color(0xFFFCD116), // Colombia Yellow
    'CHI': Color(0xFFDA291C), // Chile Red
    'PER': Color(0xFFD91023), // Peru Red
    'VEN': Color(0xFF800000), // Venezuela Vinotinto (Burgundy)
    'PAR': Color(0xFFD52B1E), // Paraguay Red
    'BOL': Color(0xFF007A33), // Bolivia Green
    
    // Europe (UEFA)
    'FRA': Color(0xFF002395), // France Dark Blue
    'ENG': Color(0xFFCE1124), // England Red
    'POR': Color(0xFFE42518), // Portugal Red
    'ESP': Color(0xFFC60B1E), // Spain Red
    'GER': Color(0xFF111111), // Germany Black/Dark Grey
    'ITA': Color(0xFF0066B2), // Italy Blue
    'NED': Color(0xFFF36C21), // Netherlands Orange
    'BEL': Color(0xFFE30613), // Belgium Red
    'CRO': Color(0xFFED1C24), // Croatia Red
    'SUI': Color(0xFFFF0000), // Switzerland Red
    'DEN': Color(0xFFC60C30), // Denmark Red
    'SWE': Color(0xFFFFC72C), // Sweden Yellow
    'POL': Color(0xFFDC143C), // Poland Red
    'SRB': Color(0xFFC6363C), // Serbia Red
    'WAL': Color(0xFFD30731), // Wales Red
    'SCO': Color(0xFF002B54), // Scotland Dark Blue
    'TUR': Color(0xFFE30A17), // Turkey Red
    'AUT': Color(0xFFED2939), // Austria Red
    'UKR': Color(0xFFFFD700), // Ukraine Yellow
    
    // North & Central America (CONCACAF)
    'USA': Color(0xFF002868), // USA Navy Blue
    'MEX': Color(0xFF006847), // Mexico Green
    'CAN': Color(0xFFFF0000), // Canada Red
    'CRC': Color(0xFFCE1126), // Costa Rica Red
    'PAN': Color(0xFFCE1126), // Panama Red
    'HON': Color(0xFF0073CF), // Honduras Blue
    'JAM': Color(0xFFFED100), // Jamaica Yellow
    
    // Asia & Australia (AFC)
    'JPN': Color(0xFF000555), // Japan Samurai Blue
    'KOR': Color(0xFFC20E1A), // South Korea Red
    'AUS': Color(0xFFFFCD00), // Australia Gold
    'KSA': Color(0xFF006C35), // Saudi Arabia Green
    'QAT': Color(0xFF8A1538), // Qatar Maroon
    'IRN': Color(0xFF239F40), // Iran Green
    'UAE': Color(0xFF00732F), // UAE Green
    'IRQ': Color(0xFF007A3D), // Iraq Green
    
    // Africa (CAF)
    'SEN': Color(0xFF00853F), // Senegal Green
    'MAR': Color(0xFFC1272D), // Morocco Red
    'CMR': Color(0xFF007A5E), // Cameroon Green
    'GHA': Color(0xFF006B3F), // Ghana Green
    'NGA': Color(0xFF008751), // Nigeria Green
    'EGY': Color(0xFFCE1126), // Egypt Red
    'TUN': Color(0xFFE70013), // Tunisia Red
    'DZA': Color(0xFF006233), // Algeria Green
    'CIV': Color(0xFFF77F00), // Ivory Coast Orange
    
    // Specials (FIFA / Panini / Coca-Cola / Legends)
    'FWC': Color(0xFF8A1538), // World Cup Logo Maroon
    '00': Color(0xFF0033A0),  // Panini Blue
    'CC': Color(0xFFF40009),  // Coca-Cola
    'LEG': Color(0xFFD4AF37), // Legends Gold (Just in case!)
  };

  // Helper method to safely get a color with a fallback
  static Color getColor(String code) {
    return countryColors[code] ?? Colors.blueAccent; // Default to blue if missing
  }
}