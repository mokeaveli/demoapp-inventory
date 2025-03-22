package live.ditto.inventory

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.text.Editable
import android.text.TextWatcher
import android.util.Log
import android.view.MenuItem
import android.view.View
import android.view.inputmethod.EditorInfo
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import live.ditto.DittoDocument
import live.ditto.DittoLiveQuery
import live.ditto.DittoLiveQueryEvent

class SearchActivity : AppCompatActivity() {
    private lateinit var searchEditText: EditText
    private lateinit var searchButton: Button
    private lateinit var resultsRecyclerView: RecyclerView
    private lateinit var noResultsTextView: TextView
    private lateinit var itemsAdapter: ItemsAdapter
    private var liveQuery: DittoLiveQuery? = null
    private val searchHandler = Handler(Looper.getMainLooper())

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_search)

        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        title = "Search Inventory"

        setupViews()
        setupListeners()
    }

    private fun setupViews() {
        searchEditText = findViewById(R.id.search_edit_text)
        searchButton = findViewById(R.id.search_button)
        resultsRecyclerView = findViewById(R.id.results_recycler_view)
        noResultsTextView = findViewById(R.id.no_results_text_view)

        itemsAdapter = ItemsAdapter()
        resultsRecyclerView.apply {
            layoutManager = LinearLayoutManager(this@SearchActivity)
            adapter = itemsAdapter
            addItemDecoration(DividerItemDecoration(this@SearchActivity, DividerItemDecoration.VERTICAL))
        }

        // Set up click listeners for the adapter
        itemsAdapter.onPlusClick = { item ->
            DittoManager.increment(item.itemId)
        }

        itemsAdapter.onMinusClick = { item ->
            DittoManager.decrement(item.itemId)
        }
    }

    private fun setupListeners() {
        searchButton.setOnClickListener {
            performSearch(searchEditText.text.toString())
        }

        // Add text change listener for real-time search with debouncing
        searchEditText.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}

            override fun afterTextChanged(s: Editable?) {
                searchHandler.removeCallbacksAndMessages(null)
                searchHandler.postDelayed({
                    performSearch(s.toString())
                }, 300) // 300ms delay
            }
        })

        // Add IME action listener for search button on keyboard
        searchEditText.setOnEditorActionListener { _, actionId, _ ->
            if (actionId == EditorInfo.IME_ACTION_SEARCH) {
                performSearch(searchEditText.text.toString())
                true
            } else {
                false
            }
        }
    }

    private fun performSearch(query: String) {
        Log.d("SearchActivity", "Performing search with query: $query")

        // Cancel any existing live query
        liveQuery?.close()

        val collection = DittoManager.ditto?.store?.collection("inventories")

        try {
            // Fetch all documents if the query is short or empty
            if (query.length < 3) {
                liveQuery = collection?.findAll()?.observeLocal { docs, event ->
                    when (event) {
                        is DittoLiveQueryEvent.Initial, is DittoLiveQueryEvent.Update -> {
                            // Filter results that contain the query string
                            val filteredDocs = if (query.isBlank()) {
                                docs
                            } else {
                                docs.filter { doc ->
                                    val title = doc["title"].stringValue ?: ""
                                    val detail = doc["detail"].stringValue ?: ""
                                    title.contains(query, ignoreCase = true) ||
                                            detail.contains(query, ignoreCase = true)
                                }
                            }
                            updateSearchResults(filteredDocs)
                        }
                        else -> {}
                    }
                }
            } else {
                // Use exact matching for longer queries
                val dqlQuery = "or(eq(title,'$query'),eq(detail,'$query'))"
                liveQuery = collection?.find(dqlQuery)?.observeLocal { docs, event ->
                    when (event) {
                        is DittoLiveQueryEvent.Initial, is DittoLiveQueryEvent.Update -> {
                            updateSearchResults(docs)
                        }
                        else -> {}
                    }
                }
            }
        } catch (e: Exception) {
            Log.e("SearchActivity", "Error executing query: ${e.message}", e)
            // Show error message to the user
            runOnUiThread {
                noResultsTextView.text = "Error searching: ${e.message}"
                noResultsTextView.visibility = View.VISIBLE
                resultsRecyclerView.visibility = View.GONE
            }
        }
    }

    private fun updateSearchResults(docs: List<DittoDocument>) {
        Log.d("SearchActivity", "Updating search results. Document count: ${docs.size}")

        val matchingItems = mutableListOf<ItemModel>()

        // Map documents to ItemModel objects
        for (doc in docs) {
            // Convert string ID to integer safely
            val itemId = doc.id.toString().toIntOrNull() ?: continue
            val item = getItemById(itemId)
            item?.let {
                it.count = doc["counter"].intValue
                matchingItems.add(it)
            }
        }

        runOnUiThread {
            if (matchingItems.isEmpty()) {
                noResultsTextView.visibility = View.VISIBLE
                resultsRecyclerView.visibility = View.GONE
            } else {
                noResultsTextView.visibility = View.GONE
                resultsRecyclerView.visibility = View.VISIBLE
                itemsAdapter.setInitial(matchingItems)
            }
        }
    }

    private fun getItemById(itemId: Int): ItemModel? {
        return DittoManager.getItemsForView().find { it.itemId == itemId }
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        if (item.itemId == android.R.id.home) {
            onBackPressed()
            return true
        }
        return super.onOptionsItemSelected(item)
    }

    override fun onDestroy() {
        super.onDestroy()
        // Clean up the live query when the activity is destroyed
        liveQuery?.close()
    }
}
