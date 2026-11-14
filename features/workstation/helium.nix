{
  environment.etc."chromium/policies/managed/helium.json".text = builtins.toJSON {
    # shortcut: prodversion = Helium 0.21.1.1's Chromium (157), bump it on a helium update; Helium omits prodversion, so the Web Store answers noupdate (imputnet/helium#1737)
    ExtensionInstallForcelist = [
      "aeblfdkhhhdcdjpifhhbdiojplfjncoa;https://clients2.google.com/service/update2/crx?prodversion=157.0"
      "omkfmpieigblcllmkgbflkikinpkodlk;https://clients2.google.com/service/update2/crx?prodversion=157.0"
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
