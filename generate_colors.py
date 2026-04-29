import os
import json

colors = {
    "aliceBlue":      {"light": [0.96, 0.95, 0.92], "dark": [0.0, 0.0, 0.0]},
    "icyBlue":        {"light": [0.91, 0.87, 0.83], "dark": [0.16, 0.12, 0.10]},
    "skyBlue":        {"light": [0.84, 0.79, 0.72], "dark": [0.22, 0.16, 0.13]},
    "coolSky":        {"light": [0.78, 0.67, 0.57], "dark": [0.30, 0.22, 0.18]},
    "coolSky2":       {"light": [0.70, 0.59, 0.49], "dark": [0.40, 0.30, 0.24]},
    "dodgerBlue":     {"light": [0.66, 0.53, 0.43], "dark": [0.50, 0.38, 0.31]},
    "brilliantAzure": {"light": [0.56, 0.42, 0.32], "dark": [0.60, 0.48, 0.40]},
    "twitterBlue":    {"light": [0.49, 0.35, 0.27], "dark": [0.72, 0.61, 0.53]},
    "oceanDeep":      {"light": [0.39, 0.27, 0.21], "dark": [0.85, 0.76, 0.69]},
    "cobaltBlue":     {"light": [0.29, 0.20, 0.16], "dark": [1.0, 1.0, 1.0]}
}

base_path = "/Users/rodolforivas/Documents/U_2026/Proyectos/Moviles_projects/multimediaApp_taber/multimediaApp_taber/Assets.xcassets"

for name, vals in colors.items():
    color_dir = os.path.join(base_path, f"{name}.colorset")
    os.makedirs(color_dir, exist_ok=True)
    
    contents = {
      "info" : {
        "author" : "xcode",
        "version" : 1
      },
      "colors" : [
        {
          "idiom" : "universal",
          "color" : {
            "color-space" : "srgb",
            "components" : {
              "red" : str(vals["light"][0]),
              "green" : str(vals["light"][1]),
              "blue" : str(vals["light"][2]),
              "alpha" : "1.000"
            }
          }
        },
        {
          "idiom" : "universal",
          "appearances" : [
            {
              "appearance" : "luminosity",
              "value" : "dark"
            }
          ],
          "color" : {
            "color-space" : "srgb",
            "components" : {
              "red" : str(vals["dark"][0]),
              "green" : str(vals["dark"][1]),
              "blue" : str(vals["dark"][2]),
              "alpha" : "1.000"
            }
          }
        }
      ]
    }
    
    with open(os.path.join(color_dir, "Contents.json"), "w") as f:
        json.dump(contents, f, indent=2)

print("Generated color assets successfully.")
