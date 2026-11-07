{
  description = "Gatuno app development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    jaoppb-tools = {
      url = "github:jaoppb/tools/v0.2.0";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      jaoppb-tools,
      ...
    }:
    flake-utils.lib.eachSystem
      [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ]
      (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config = {
              allowUnfree = true;
              android_sdk.accept_license = true;
            };
          };

          # Gradle files in android/ target Java 17.
          jdk = pkgs.jdk17;

          androidComposition = pkgs.androidenv.composeAndroidPackages {
            platformVersions = [
              "34"
              "35"
              "36"
            ];
            buildToolsVersions = [
              "34.0.0"
              "35.0.0"
              "36.0.0"
            ];
            # Flutter's doctor checks every license sdkmanager knows about.
            extraLicenses = [
              "android-googletv-license"
              "android-googlexr-license"
              "android-sdk-arm-dbt-license"
              "android-sdk-preview-license"
              "google-gdk-license"
              "intel-android-extra-license"
              "intel-android-sysimage-license"
              "microxr-sysimage-license"
              "mips-android-sysimage-license"
            ];
            includeNDK = true;
            includeEmulator = false;
            includeSystemImages = false;
          };
          androidSdk = androidComposition.androidsdk;
          androidSdkRoot = "${androidSdk}/libexec/android-sdk";
        in
        {
          devShells.default = pkgs.mkShell {
            packages = [
              pkgs.flutter
              jdk
              androidSdk
              pkgs.just
              pkgs.lefthook
              pkgs.git
              jaoppb-tools.packages.${system}.issues-check
              jaoppb-tools.packages.${system}.repo-sync
            ];

            JAVA_HOME = jdk.home;
            ANDROID_HOME = androidSdkRoot;
            ANDROID_SDK_ROOT = androidSdkRoot;
          };

          formatter = pkgs.nixfmt;
        }
      );
}
