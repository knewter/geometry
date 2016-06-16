{- This Source Code Form is subject to the terms of the Mozilla Public License,
   v. 2.0. If a copy of the MPL was not distributed with this file, you can
   obtain one at http://mozilla.org/MPL/2.0/.

   Copyright 2016 by Ian Mackenzie
   ian.e.mackenzie@gmail.com
-}


module OpenSolid.Core.Vector3d
    exposing
        ( zero
        , alongAxis
        , onPlane
        , perpendicularTo
        , xComponent
        , yComponent
        , zComponent
        , componentIn
        , length
        , squaredLength
        , direction
        , negate
        , plus
        , minus
        , times
        , dotProduct
        , crossProduct
        , rotateAround
        , mirrorAcross
        , projectOntoAxis
        , projectOnto
        , projectInto
        , toLocalIn
        , fromLocalIn
        , components
        , fromComponents
        , toRecord
        , fromRecord
        )

{-| Various functions for constructing `Vector3d` values and performing
operations on them. For the examples below, assume the following imports:

    import OpenSolid.Core.Types exposing (..)
    import OpenSolid.Core.Vector3d as Vector3d
    import OpenSolid.Core.Direction3d as Direction3d
    import OpenSolid.Core.Frame3d as Frame3d

Examples use `==` to indicate that two expressions are equivalent, even if (due
to numerical roundoff) they might not be exactly equal.

# Constants

@docs zero

Although there are no predefined constants for `Vector2d 1 0 0`,
`Vector2d 0 1 0` and `Vector2d 0 0 1`, in most cases you will actually want
their `Direction3d` versions `Direction3d.x`, `Direction3d.y` and
`Direction3d.z`.

# Constructors

Since `Vector3d` is not an opaque type, the simplest way to construct one is
directly from its X, Y and Z components, for example `Vector2d 2 3 4`. But that
is not the only way!

@docs alongAxis, onPlane, perpendicularTo

# Components

@docs xComponent, yComponent, zComponent, componentIn

# Length and direction

@docs length, squaredLength, direction

# Arithmetic

@docs negate, plus, minus, times, dotProduct, crossProduct

# Transformations

@docs rotateAround, mirrorAcross, projectOntoAxis, projectOnto

# Local coordinates

Functions for transforming vectors between local and global coordinates in
different coordinate frames.

@docs projectInto, toLocalIn, fromLocalIn

# Conversions

Various ways to convert to and from plain tuples and records. Primarily useful
for interoperability with other libraries. For example, you could define
conversion functions to and from `elm-linear-algebra`'s `Vec3` type with

    toVec3 : Vector3d -> Math.Vector3.Vec3
    toVec3 =
        Vector3d.components >> Math.Vector3.fromTuple

    fromVec3 : Math.Vector3.Vec3 -> Vector3d
    fromVec3 =
        Math.Vector3.toTuple >> Vector3d.fromComponents

@docs components, fromComponents, toRecord, fromRecord
-}

import OpenSolid.Core.Types exposing (..)


zero : Vector3d
zero =
    Vector3d 0 0 0


alongAxis : Axis3d -> Float -> Vector3d
alongAxis axis magnitude =
    let
        (Direction3d directionVector) =
            axis.direction
    in
        times magnitude directionVector


onPlane : Plane3d -> Vector2d -> Vector3d
onPlane plane =
    let
        (Direction3d (Vector3d x1 y1 z1)) =
            plane.xDirection

        (Direction3d (Vector3d x2 y2 z2)) =
            plane.yDirection
    in
        \(Vector2d x y) ->
            Vector3d (x1 * x + x2 * y) (y1 * x + y2 * y) (z1 * x + z2 * y)


perpendicularTo : Vector3d -> Vector3d
perpendicularTo (Vector3d x y z) =
    let
        absX =
            abs x

        absY =
            abs y

        absZ =
            abs z
    in
        if absX <= absY then
            if absX <= absZ then
                Vector3d 0 (-z) y
            else
                Vector3d (-y) x 0
        else if absY <= absZ then
            Vector3d z 0 (-x)
        else
            Vector3d (-y) x 0


xComponent : Vector3d -> Float
xComponent (Vector3d x _ _) =
    x


yComponent : Vector3d -> Float
yComponent (Vector3d _ y _) =
    y


zComponent : Vector3d -> Float
zComponent (Vector3d _ _ z) =
    z


componentIn : Direction3d -> Vector3d -> Float
componentIn (Direction3d vector) =
    dotProduct vector


length : Vector3d -> Float
length =
    squaredLength >> sqrt


squaredLength : Vector3d -> Float
squaredLength (Vector3d x y z) =
    x * x + y * y + z * z


{-| Attempt to find the direction of a vector. In the case of a zero vector,
return `Nothing`.

    Vector3d.direction (Vector3d 1 0 1) == Just (Direction3d (Vector3d 0.7071 0 0.7071))
    Vector3d.direction (Vector3d 0 0 0) == Nothing

For instance, given an eye point and a point to look at, the corresponding view
direction could be determined with

    Vector3d.direction (Point3d.vectorFrom eyePoint lookAtPoint)

This would return a `Maybe Direction3d`, with `Nothing` corresponding to the
case where the eye point and point to look at are coincident (in which case the
view direction is not well-defined and some special-case logic is needed).

If you can *guarantee* that a vector is non-zero and don't want to deal with a
`Maybe`, you can use `Direction3d.ofNonZeroVector` instead.
-}
direction : Vector3d -> Maybe Direction3d
direction vector =
    if vector == zero then
        Nothing
    else
        Just (Direction3d (times (1 / length vector) vector))


negate : Vector3d -> Vector3d
negate (Vector3d x y z) =
    Vector3d (-x) (-y) (-z)


plus : Vector3d -> Vector3d -> Vector3d
plus (Vector3d x2 y2 z2) (Vector3d x1 y1 z1) =
    Vector3d (x1 + x2) (y1 + y2) (z1 + z2)


minus : Vector3d -> Vector3d -> Vector3d
minus (Vector3d x2 y2 z2) (Vector3d x1 y1 z1) =
    Vector3d (x1 - x2) (y1 - y2) (z1 - z2)


times : Float -> Vector3d -> Vector3d
times scale (Vector3d x y z) =
    Vector3d (x * scale) (y * scale) (z * scale)


dotProduct : Vector3d -> Vector3d -> Float
dotProduct (Vector3d x1 y1 z1) (Vector3d x2 y2 z2) =
    x1 * x2 + y1 * y2 + z1 * z2


crossProduct : Vector3d -> Vector3d -> Vector3d
crossProduct (Vector3d x1 y1 z1) (Vector3d x2 y2 z2) =
    Vector3d (y1 * z2 - z1 * y2) (z1 * x2 - x1 * z2) (x1 * y2 - y1 * x2)


rotateAround : Axis3d -> Float -> Vector3d -> Vector3d
rotateAround axis angle =
    let
        (Direction3d (Vector3d dx dy dz)) =
            axis.direction

        halfAngle =
            0.5 * angle

        sinHalfAngle =
            sin halfAngle

        x =
            dx * sinHalfAngle

        y =
            dy * sinHalfAngle

        z =
            dz * sinHalfAngle

        w =
            cos halfAngle

        wx =
            w * x

        wy =
            w * y

        wz =
            w * z

        xx =
            x * x

        xy =
            x * y

        xz =
            x * z

        yy =
            y * y

        yz =
            y * z

        zz =
            z * z

        a00 =
            1 - 2 * (yy + zz)

        a10 =
            2 * (xy + wz)

        a20 =
            2 * (xz - wy)

        a01 =
            2 * (xy - wz)

        a11 =
            1 - 2 * (xx + zz)

        a21 =
            2 * (yz + wx)

        a02 =
            2 * (xz + wy)

        a12 =
            2 * (yz - wx)

        a22 =
            1 - 2 * (xx + yy)
    in
        \(Vector3d vx vy vz) ->
            let
                vx' =
                    a00 * vx + a01 * vy + a02 * vz

                vy' =
                    a10 * vx + a11 * vy + a12 * vz

                vz' =
                    a20 * vx + a21 * vy + a22 * vz
            in
                Vector3d vx' vy' vz'


mirrorAcross : Plane3d -> Vector3d -> Vector3d
mirrorAcross plane =
    let
        (Direction3d (Vector3d dx dy dz)) =
            plane.normalDirection

        a =
            1 - 2 * dx * dx

        b =
            1 - 2 * dy * dy

        c =
            1 - 2 * dz * dz

        d =
            -2 * dy * dz

        e =
            -2 * dx * dz

        f =
            -2 * dx * dy
    in
        \(Vector3d vx vy vz) ->
            let
                vx' =
                    a * vx + f * vy + e * vz

                vy' =
                    f * vx + b * vy + d * vz

                vz' =
                    e * vx + d * vy + c * vz
            in
                Vector3d vx' vy' vz'


projectOntoAxis : Axis3d -> Vector3d -> Vector3d
projectOntoAxis axis vector =
    let
        (Direction3d directionVector) =
            axis.direction
    in
        times (dotProduct vector directionVector) directionVector


projectOnto : Plane3d -> Vector3d -> Vector3d
projectOnto plane vector =
    let
        normalAxis =
            Axis3d plane.originPoint plane.normalDirection
    in
        minus (projectOntoAxis normalAxis vector) vector


toLocalIn : Frame3d -> Vector3d -> Vector3d
toLocalIn frame vector =
    let
        x =
            componentIn frame.xDirection vector

        y =
            componentIn frame.yDirection vector

        z =
            componentIn frame.zDirection vector
    in
        Vector3d x y z


fromLocalIn : Frame3d -> Vector3d -> Vector3d
fromLocalIn frame =
    let
        (Direction3d (Vector3d x1 y1 z1)) =
            frame.xDirection

        (Direction3d (Vector3d x2 y2 z2)) =
            frame.yDirection

        (Direction3d (Vector3d x3 y3 z3)) =
            frame.zDirection
    in
        \(Vector3d x y z) ->
            let
                x' =
                    x1 * x + x2 * y + x3 * z

                y' =
                    y1 * x + y2 * y + y3 * z

                z' =
                    z1 * x + z2 * y + z3 * z
            in
                Vector3d x' y' z'


projectInto : Plane3d -> Vector3d -> Vector2d
projectInto plane vector =
    Vector2d (componentIn plane.xDirection vector)
        (componentIn plane.yDirection vector)


components : Vector3d -> ( Float, Float, Float )
components (Vector3d x y z) =
    ( x, y, z )


fromComponents : ( Float, Float, Float ) -> Vector3d
fromComponents ( x, y, z ) =
    Vector3d x y z


toRecord : Vector3d -> { x : Float, y : Float, z : Float }
toRecord (Vector3d x y z) =
    { x = x, y = y, z = z }


fromRecord : { x : Float, y : Float, z : Float } -> Vector3d
fromRecord { x, y, z } =
    Vector3d x y z