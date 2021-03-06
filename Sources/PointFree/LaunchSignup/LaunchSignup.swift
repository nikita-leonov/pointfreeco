import Either
import Foundation
import Html
import HttpPipeline
import HttpPipelineHtmlSupport
import Prelude

let homeResponse =
  analytics
    >>> map(writeStatus(.ok))
    >>> map(respond(launchSignupView))

let signupResponse =
  analytics
    >-> airtableStuff
    >>> map(redirect(to: link(to: .home(signedUpSuccessfully: true))))

private func airtableStuff<I>(_ conn: Conn<I, String>) -> IO<Conn<I, Either<Prelude.Unit, Prelude.Unit>>> {

  let result = [EnvVars.airbaseBase1, EnvVars.airbaseBase2, EnvVars.airbaseBase3]
    .map(AppEnvironment.current.airtableStuff(conn.data))
    .reduce(lift(.left(unit))) { $0 <|> $1 }
    .run

  return result.map { conn.map(const($0)) }
}

private func analytics<I, A>(_ conn: Conn<I, A>) -> IO<Conn<I, A>> {
  return IO {
    print("tracked analytics")
    return conn
  }
}
