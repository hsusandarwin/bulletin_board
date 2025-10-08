# bulletin_board

### Setup Flutter Version Management (FVM)

fvm install 3.35.3

fvm use 3.35.3

flutter clean

fvm flutter pub get
```

### Running Build Runner for Code Generation

```shell
fvm flutter pub run build_runner build --delete-conflicting-outputs
or
flutter pub run build_runner build --delete-conflicting-output
```

### Run Project In Development

```shell
fvm flutter run 
```

