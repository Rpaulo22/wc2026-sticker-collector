// Class holding data about existing sticker groups, and mappings for flags and translation to portuguese
import 'package:circle_flags/circle_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class StickerData {
  static Widget getFlagAvatar(String countryCode) {
    bool hasFlag = paniniToIso.containsKey(countryCode);

    // manually check for England
    if (countryCode == 'ENG') {
      return SvgPicture.asset('assets/images/gb-eng.svg', width: 24, height: 24, fit: BoxFit.cover);
    }
    
    // manually check for Scotland
    if (countryCode == 'SCO') {
      return SvgPicture.asset('assets/images/gb-sct.svg', width: 24, height: 24, fit: BoxFit.cover);
    }
    
    // use package for remaining countries
    if (hasFlag) {
      return CircleFlag(paniniToIso[countryCode]!, size: 24);
    }
    
    // for "00", "FWC", etc.
    return const Icon(Icons.star, size: 20, color: Colors.amber);
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
}