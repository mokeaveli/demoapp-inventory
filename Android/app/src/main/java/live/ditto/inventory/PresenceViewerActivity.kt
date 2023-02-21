package live.ditto.inventory

import android.os.Bundle
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import live.ditto.inventory.R
import live.ditto.dittopresenceviewer.PresenceViewModel
import live.ditto.dittopresenceviewer.PresenceViewerFragment

class PresenceViewerActivity : AppCompatActivity() {

    private val viewModel: PresenceViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_presence_viewer)

        if (savedInstanceState == null) {

            if (DittoManager.ditto == null) {
                finish()
                return
            }

            viewModel.ditto = DittoManager.ditto
            supportFragmentManager.beginTransaction()
                .replace(R.id.container, PresenceViewerFragment.newInstance())
                .commitNow()
        }
    }
}
