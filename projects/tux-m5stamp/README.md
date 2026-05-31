# Boîtier « Tux » pour M5Stamp S3

Boîtier décoratif en forme de **pingouin (Tux)** pour une carte **M5Stamp S3** (ESP32-S3). Multi-pièces et multicolore : coque noire, ventre/visage blanc, bec et pieds jaunes. La **tête (coque haute) se retire au niveau du col** pour installer la carte.

![Aperçu](v4d_preview.png) ![Éclaté](v4d_exploded.png)

## Pièces

| Pièce | STL | Couleur | Rôle |
|---|---|---|---|
| Coque haute (tête + haut du corps) | `stl/tux_case_top.stl` | noir | se retire au col ; reçoit les pions d'alignement |
| Coque basse (bas du corps) | `stl/tux_case_bottom.stl` | noir | loge la carte ; ouverture USB |
| Ventre + visage | `stl/tux_belly.stl` | blanc | insert (1,6 mm) qui se loge dans le renfoncement avant |
| Bec | `stl/tux_beak.stl` | jaune | emboîté par tenon (Ø 4) |
| Pied gauche / droit | `stl/tux_foot_left.stl`, `stl/tux_foot_right.stl` | jaune | emboîtés par tenon (Ø 4) |

## Carte et assemblage

- **M5Stamp S3** : 18,4 × 24,4 × 9,6 mm, prise **USB-C** (ouverture 10 × 4,2 mm), jeu `tol = 0,3 mm`.
- La carte se pose dans la **coque basse** ; la **coque haute** vient par-dessus, **alignée par 2 pions** (Ø 3,5 mm) au niveau du plan de séparation (`split_z = 4`).
- Le **ventre/visage** blanc se clipse dans le renfoncement avant ; **bec** et **pieds** s'emboîtent par tenons (collage possible).

## ⚠️ À corriger avant impression

Les **deux coques** (`tux_case_top`, `tux_case_bottom`) sortent actuellement en **3 corps non reliés** (étanches mais séparés) :
- sur la coque basse, ce sont les **2 pions d'alignement**, posés **au-dessus de la cavité** → ils ne sont **pas soudés à la coque** et s'imprimeraient « en l'air » ;
- sur la coque haute, 2 petits éléments détachés sur les côtés.

→ Il faut **rattacher ces éléments à la coque** (les pions sur le rebord/col, pas au-dessus du vide) avant d'imprimer. Les pièces **bec / pieds / ventre** sont, elles, propres (un seul corps étanche).

## Impression

- Multicolore : imprimante **AMS/MMU**, ou imprimer chaque pièce séparément dans le bon filament (noir / blanc / jaune) puis assembler.
- Intérieur (PLA/PETG) suffit ; pas de contrainte mécanique.
- Les STL des coques sont exportés **prêts à poser** (`case_top` est déjà retourné).

## Régénérer les STL

```bash
for p in case_top case_bottom belly beak foot_left foot_right; do
  openscad -o stl/tux_$p.stl -D "part=\"$p\"" tux_m5stamp.scad
done
```

Aperçu dans OpenSCAD : paramètre `part` = `preview`, `exploded`, `case_top`, `case_bottom`, `belly`, `beak`, `foot_left`, `foot_right`.

## Fichiers

```
projects/tux-m5stamp/
├── README.md
├── tux_m5stamp.scad     (source paramétrique)
├── stl/                 (6 pièces)
└── v4d_*.png            (rendus : preview, exploded, front, face_zoom, belly_only)
```
