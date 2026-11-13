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

          # Gradle asks for the NDK in `flutter.ndkVersion`, which Flutter
          # hard-codes in this file. The Nix store is read-only, so Gradle cannot
          # install a missing NDK itself. Reading the version from the Flutter SDK
          # the shell ships (import-from-derivation) keeps the NDK in sync when
          # flake.lock bumps Flutter. If Flutter moves the constant, fail loudly
          # rather than ship an NDK that Gradle will reject.
          flutterNdkFile = "${pkgs.flutter.unwrapped}/packages/flutter_tools/gradle/src/main/kotlin/FlutterExtension.kt";
          flutterNdkPattern = ''[[:space:]]*val ndkVersion: String = "([0-9]+\.[0-9]+\.[0-9]+)".*'';
          flutterNdkMatches = builtins.filter (m: m != null) (
            map (builtins.match flutterNdkPattern) (
              pkgs.lib.splitString "\n" (builtins.readFile flutterNdkFile)
            )
          );
          flutterNdkVersion =
            if builtins.length flutterNdkMatches == 1 then
              builtins.head (builtins.head flutterNdkMatches)
            else
              throw ''
                flake.nix: expected exactly one line matching
                  ${flutterNdkPattern}
                in ${flutterNdkFile}, found ${toString (builtins.length flutterNdkMatches)}.
                Flutter moved its NDK version constant: update flutterNdkPattern, or
                set ndkVersions to the value of `flutter.ndkVersion` by hand.
              '';

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
            # List = repo.json licenses in nixpkgs androidenv minus the default
            # android-sdk-license; refresh it when `flutter doctor` reports
            # unaccepted licenses.
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
            ndkVersions = [ flutterNdkVersion ];
            # CMake for plugins with native code (e.g. jni). They leave the version
            # to the Android Gradle Plugin, whose default is 3.22.1 for the AGP in
            # android/settings.gradle.kts (8.11.1). Re-check when bumping AGP.
            includeCmake = true;
            cmakeVersions = [ "3.22.1" ];
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
              pkgs.python3
              jaoppb-tools.packages.${system}.issues-check
              jaoppb-tools.packages.${system}.repo-sync
            ];

            JAVA_HOME = jdk.home;
            ANDROID_HOME = androidSdkRoot;
            ANDROID_SDK_ROOT = androidSdkRoot;
          };

          # Lean shell for CI analyze/test: Flutter only (Dart ships with it). Nix evaluates
          # `let` bindings lazily, so this does not touch androidSdk or the NDK
          # import-from-derivation above.
          devShells.ci = pkgs.mkShell {
            packages = [ pkgs.flutter ];
          };

          formatter = pkgs.nixfmt;
        }
      );
}
