package im.tox.client

import im.tox.tox4j.core.enums.ToxStatus
import org.scalatest.FlatSpec

class ToxClientSpec extends FlatSpec {

  def with_tox(code: ToxClient => Unit) = {
    val tox = new ToxClient
    try {
      code(tox)
    } finally {
      tox.close()
    }
  }

  "getName" should "return the name set by setName" in {
    with_tox { tox =>
      tox.name = "Alice"
      assert(tox.name == "Alice")
    }
  }

  it must "return an empty string if no name was set" in {
    with_tox { tox =>
      assert(tox.name == "")
    }
  }


  "getStatus" should "return the status set by setStatus" in {
    with_tox { tox =>
      assert(tox.status == ToxStatus.NONE)
      tox.status = ToxStatus.AWAY
      assert(tox.status == ToxStatus.AWAY)
    }
  }

  it should "return NONE if no status was set" in {
    with_tox { tox =>
      assert(tox.status == ToxStatus.NONE)
    }
  }


  "getStatusMessage" should "return the status message set by setStatusMessage" in {
    with_tox { tox =>
      tox.statusMessage = "Yo, cool status"
      assert(tox.statusMessage == "Yo, cool status")
    }
  }

  it should "return an empty string if no status message was set" in {
    with_tox { tox =>
      assert(tox.statusMessage == "")
    }
  }

}
