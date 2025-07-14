// scripts/remove-locales.js
const {join} = require("path");
const {readdirSync, unlinkSync, existsSync} = require("fs");

exports.default = async function (context) {
  const appOutDir = context.appOutDir;

  // Supprime toutes les locales sauf fr.pak
  const localeDir = join(appOutDir, "locales");
  if (existsSync(localeDir)) {
    readdirSync(localeDir)
      .filter((f) => f !== "fr.pak")
      .forEach((f) => unlinkSync(join(localeDir, f)));
  }

  // Supprime tous les dictionnaires
  const dictDir = join(appOutDir, "dictionaries");
  if (existsSync(dictDir)) {
    readdirSync(dictDir)
      .forEach((f) => unlinkSync(join(dictDir, f)));
  }

  // fichiers inutiles
  [
    join(appOutDir, "ressources") + "/default_app.asar",
    join(appOutDir, "ressources") + "/app/node_modules/.bin",
    join(appOutDir, "ressources") + "/v8_context_snapshot.bin",
    join(appOutDir, "ressources") + "/snapshot_blob.bin",
    join(appOutDir, "ressources") + "/swiftshader",
  ].forEach((file) => {
    if (existsSync(file)) {
      unlinkSync(file);
    }
  })
};
