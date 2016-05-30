{- This Source Code Form is subject to the terms of the Mozilla Public License,
   v. 2.0. If a copy of the MPL was not distributed with this file, you can
   obtain one at http://mozilla.org/MPL/2.0/.

   Copyright 2016 by Ian Mackenzie
   ian.e.mackenzie@gmail.com
-}


module Test.Direction2d exposing (suite)

import Json.Decode as Decode exposing (decodeValue)
import Json.Encode as Encode
import ElmTest exposing (Test)
import Check exposing (Claim, claim, true, that, is, for, quickCheck)
import Check.Test exposing (evidenceToTest)
import OpenSolid.Core.Types exposing (..)
import OpenSolid.Core.Decode as Decode
import OpenSolid.Core.Encode as Encode
import Test.Producers exposing (direction2d)


jsonRoundTrips : Claim
jsonRoundTrips =
    claim "JSON conversion round-trips properly"
        `that` (Encode.direction2d >> decodeValue Decode.direction2d)
        `is` Ok
        `for` direction2d


suite : Test
suite =
    ElmTest.suite "Direction2d tests"
        [ evidenceToTest (quickCheck jsonRoundTrips)
        ]