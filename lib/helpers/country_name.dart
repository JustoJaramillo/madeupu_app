import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';

class CountryName {
  static String gettingName(String phoneCode) {
    if (phoneCode == '00') {
      return 'Select Country (SC)';
    }
    Country country = CountryPickerUtils.getCountryByPhoneCode(phoneCode);
    return '${country.name} (${country.isoCode})';
  }
}
