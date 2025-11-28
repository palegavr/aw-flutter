dart run build_runner build
dart run drift_dev make-migrations


pushd build\windows\x64\runner\Debug
del db.sqlite
popd


flutter_rust_bridge_codegen generate