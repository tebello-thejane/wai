{-# LANGUAGE EmptyCase, EmptyDataDecls, RankNTypes #-}
module Network.Wai.HTTP2
    ( Http2Application
    , Response
    , Trailers
    , absurd
    , responseStatus
    , responseStream
    , responseHeaders
    ) where

import           Blaze.ByteString.Builder     (Builder)
import qualified Network.HTTP.Types as H

import qualified Network.Wai.Internal as H1 (Request)

-- | Headers sent after the end of a data stream, as defined by section 4.1.2 of
-- the HTTP\/1.1 spec (RFC 7230), and section 8.1 of the HTTP\/2 spec.
type Trailers = [H.Header]

-- | The synthesized request and headers of a pushed stream.
-- TODO(awpr): implement for real.
data PushPromise

-- 'PushPromise' is currently uninhabited, which proves the caller cannot use
-- 'pushPromise'.  This discharges the obligation to implement any function
-- taking a 'PushPromise'.
absurd :: PushPromise -> a
absurd p = case p of {}

-- | The type of an HTTP\/2 request: a normal HTTP request and an action to
-- push streams associated with this request.
type Request = (H1.Request, PushPromise -> Responder -> IO ())

-- | The HTTP\/2-aware equivalent of 'Network.Wai.Application'.
type Http2Application = Request -> Responder

type Body a = (Builder -> IO ()) -> IO () -> IO a

type Response a = (H.Status, H.ResponseHeaders, Body a)

type Responder = (forall a. Response a -> IO a) -> IO Trailers

responseStatus :: Response a -> H.Status
responseStatus (s, _, _) = s

responseHeaders :: Response a -> H.ResponseHeaders
responseHeaders (_, h, _) = h

responseStream :: H.Status -> H.ResponseHeaders -> Body a -> Response a
responseStream = (,,)
