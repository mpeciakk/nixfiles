{
  environment.etc."chromium/policies/managed/helium.json".text = builtins.toJSON {
    ExtensionInstallForcelist = [
      "aeblfdkhhhdcdjpifhhbdiojplfjncoa;https://clients2.google.com/service/update2/crx"
      "omkfmpieigblcllmkgbflkikinpkodlk;https://clients2.google.com/service/update2/crx"
    ];
    DefaultSearchProviderEnabled = true;
    DefaultSearchProviderName = "Google";
    DefaultSearchProviderKeyword = "google.com";
    DefaultSearchProviderSearchURL = "https://www.google.com/search?q={searchTerms}";
    DefaultSearchProviderSuggestURL = "https://www.google.com/complete/search?client=chrome&q={searchTerms}";
    PasswordManagerEnabled = false;
    AutofillAddressEnabled = false;
    AutofillCreditCardEnabled = false;
  };
}
