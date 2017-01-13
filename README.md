## What is it?

An [Elm](http://elm-lang.org) package for working with 2D and 3D geometry, for
use when developing software such as computer aided design apps, simulations and
games. Instead of writing your own 3D point/vector types and transformation
functions, give `opensolid/geometry` a try!  A wide variety of geometric data
types are supported:

  - `Point2d`, `Point3d`

    ![Point2d](https://opensolid.github.io/images/geometry/icons/point2d.svg)
    ![Point3d](https://opensolid.github.io/images/geometry/icons/point3d.svg)

  - `Vector2d`, `Vector3d`

    ![Vector2d](https://opensolid.github.io/images/geometry/icons/vector2d.svg)
    ![Vector3d](https://opensolid.github.io/images/geometry/icons/vector3d.svg)

  - `Direction2d`, `Direction3d` (type-safe unit vectors)

    ![Direction2d](https://opensolid.github.io/images/geometry/icons/direction2d.svg)
    ![Direction3d](https://opensolid.github.io/images/geometry/icons/direction3d.svg)

  - `Axis2d`, `Axis3d`, `Plane3d`

    ![Axis2d](https://opensolid.github.io/images/geometry/icons/axis2d.svg)
    ![Axis3d](https://opensolid.github.io/images/geometry/icons/axis3d.svg)
    ![Plane3d](https://opensolid.github.io/images/geometry/icons/plane3d.svg)

  - `Frame2d`, `Frame3d` (local coordinate systems)

    ![Frame2d](https://opensolid.github.io/images/geometry/icons/frame2d.svg)
    ![Frame3d](https://opensolid.github.io/images/geometry/icons/frame3d.svg)

  - `SketchPlane3d` (local 2D coordinate system embedded in 3D)

    ![SketchPlane3d](https://opensolid.github.io/images/geometry/icons/sketchPlane3d.svg)

  - `BoundingBox2d`, `BoundingBox3d`

    ![BoundingBox2d](https://opensolid.github.io/images/geometry/icons/boundingBox2d.svg)
    ![BoundingBox3d](https://opensolid.github.io/images/geometry/icons/boundingBox3d.svg)

  - `LineSegment2d`, `LineSegment3d`

    ![LineSegment2d](https://opensolid.github.io/images/geometry/icons/lineSegment2d.svg)
    ![LineSegment3d](https://opensolid.github.io/images/geometry/icons/lineSegment3d.svg)

  - `Triangle2d`, `Triangle3d`

    ![Triangle2d](https://opensolid.github.io/images/geometry/icons/triangle2d.svg)
    ![Triangle3d](https://opensolid.github.io/images/geometry/icons/triangle3d.svg)

  - `Polyline2d`, `Polyline3d`, `Polygon2d`

    ![Polyline2d](https://opensolid.github.io/images/geometry/icons/polyline2d.svg)
    ![Polyline3d](https://opensolid.github.io/images/geometry/icons/polyline3d.svg)
    ![Polygon2d](https://opensolid.github.io/images/geometry/icons/polygon2d.svg)

  - and last but not least `Circle2d`

    ![Circle2d](https://opensolid.github.io/images/geometry/icons/circle2d.svg)

A large range of geometric functionality is included, such as various forms of
constructors...

```elm
Direction2d.fromAngle (degrees 30)
-- Direction2d ( 0.866, 0.5 )

Point3d.midpoint Point3d.origin (Point3d (1, 4, 5))
-- Point3d ( 0.5, 2, 2.5 )

localFrame =
    Frame2d.at (Point2d ( 2, 3 ))
```

...point/vector arithmetic...

```elm
Vector3d.plus (Vector3d ( 1, 2, 3 )) (Vector3d ( 4, 5, 6 ))
-- Vector3d ( 5, 7, 9 )

Point3d.vectorFrom (Point3d ( 1, 1, 1 )) (Point3d ( 3, 5, 4 ))
-- Vector3d ( 2, 4, 3 )

Point2d.distanceFrom Point2d.origin (Point2d ( 1, 1 ))
-- 1.4142
```

...2D/3D transformations...

```elm
Point3d.mirrorAcross Plane3d.xy (Point3d ( 1, 2, 3 ))
-- Point3d ( 1, 2, -3 )

Vector2d.rotateBy (degrees 45) (Vector2d ( 1, 1 ))
-- Vector2d ( 0, 1.4142 )

Point2d.rotateAround Point2d.origin (degrees 45) (Point2d ( 1, 0 ))
-- Point2d ( 0.7071, 0.7071 )

Vector3d.projectionIn Direction3d.z (Vector3d ( 3, 1, 4 ))
-- Vector3d ( 0, 0, 4 )

rotatedTriangle =
    Triangle3d.rotateAround Axis3d.x (degrees 45) triangle

transformedLineSegment =
    lineSegment
        |> LineSegment3d.mirrorAcross Plane3d.yz
        |> LineSegment3d.projectOnto Plane3d.xy

raisedPlane =
    Plane3d.offsetBy 3 Plane3d.xy
```

...and conversions between coordinate systems:

```elm
rotatedFrame =
    Frame2d.xy |> Frame2d.rotateBy (degrees 30)

Vector2d.relativeTo rotatedFrame (Vector2d ( 2, 0 ))
-- Vector2d ( 1.7321, -1 )

Point3d.projectInto SketchPlane3d.yz (Point3d ( 2, 1, 3 ))
-- Point2d ( 1, 3 )
```

JSON encoders and decoders for all types are also provided in the `Encode` and
`Decode` modules.

## How do I use it?

To install, run

```
elm package install opensolid/geometry
```

or add

```json
"opensolid/geometry": "1.0.0 <= v < 2.0.0"
```

to your `elm-package.json`.

Full API documentation is available for each module. Most modules are associated
with a particular type; for an overview of the various types in the package,
check out the `OpenSolid.Geometry.Types` module.

Most OpenSolid modules are designed to imported as qualified. The main exception
is the `Types` module, which only contains type definitions and is intended to
be imported without qualification. For example,

```elm
import OpenSolid.Geometry.Types exposing (..)
import OpenSolid.Point3d as Point3d
import OpenSolid.Vector2d as Vector2d
```

All documentation examples assume that `OpenSolid.Geometry.Types` and any other
necessary modules have been imported using this pattern.
