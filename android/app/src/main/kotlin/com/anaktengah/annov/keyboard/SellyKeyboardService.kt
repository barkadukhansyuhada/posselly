package com.anaktengah.annov.keyboard

import android.content.Context
import android.inputmethodservice.InputMethodService
import android.view.View
import android.view.inputmethod.InputConnection
import android.widget.Button
import android.widget.GridLayout
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import androidx.core.content.ContextCompat
import com.anaktengah.annov.R

class SellyKeyboardService : InputMethodService() {
    
    private lateinit var keyboardView: View
    private lateinit var templatesContainer: LinearLayout
    private lateinit var actionsContainer: GridLayout
    
    private val quickTemplates = mapOf(
        "Salam" to "Selamat datang di toko kami! 😊",
        "Promosi" to "🎉 PROMO SPESIAL! Dapatkan diskon hingga 50% untuk pembelian hari ini!",
        "Konfirmasi" to "Terima kasih sudah order! Pesanan Anda sedang kami proses. Estimasi pengiriman 1-2 hari kerja.",
        "Ongkir" to "Ongkos kirim ke kota Anda:",
        "Stok" to "Stok masih tersedia! Buruan order sebelum kehabisan 📦",
        "Terima Kasih" to "Terima kasih sudah berbelanja di toko kami! Ditunggu orderan selanjutnya ya 🙏"
    )
    
    private val quickActions = listOf(
        "📋 Buat Invoice",
        "📦 Cek Stok", 
        "🚚 Hitung Ongkir",
        "💰 Kalkulator"
    )

    override fun onCreateInputView(): View {
        keyboardView = layoutInflater.inflate(R.layout.keyboard_layout, null)
        
        templatesContainer = keyboardView.findViewById(R.id.templatesContainer)
        actionsContainer = keyboardView.findViewById(R.id.actionsContainer)
        
        setupTemplateButtons()
        setupActionButtons()
        setupControlButtons()
        
        return keyboardView
    }
    
    private fun setupTemplateButtons() {
        templatesContainer.removeAllViews()
        
        for ((title, content) in quickTemplates) {
            val button = createTemplateButton(title, content)
            templatesContainer.addView(button)
        }
    }
    
    private fun createTemplateButton(title: String, content: String): Button {
        val button = Button(this).apply {
            text = title
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                marginStart = 8
                marginEnd = 8
            }
            
            background = ContextCompat.getDrawable(context, R.drawable.template_button_bg)
            setTextColor(ContextCompat.getColor(context, R.color.primary_color))
            textSize = 12f
            setPadding(24, 12, 24, 12)
            isAllCaps = false
            
            setOnClickListener {
                insertText(content)
            }
        }
        return button
    }
    
    private fun setupActionButtons() {
        actionsContainer.removeAllViews()
        actionsContainer.columnCount = 2
        
        for (action in quickActions) {
            val button = createActionButton(action)
            actionsContainer.addView(button)
        }
    }
    
    private fun createActionButton(action: String): Button {
        val button = Button(this).apply {
            text = action
            layoutParams = GridLayout.LayoutParams().apply {
                columnSpec = GridLayout.spec(GridLayout.UNDEFINED, 1f)
                width = 0
                height = GridLayout.LayoutParams.WRAP_CONTENT
                setMargins(4, 4, 4, 4)
            }
            
            background = ContextCompat.getDrawable(context, R.drawable.action_button_bg)
            setTextColor(ContextCompat.getColor(context, android.R.color.white))
            textSize = 11f
            setPadding(16, 16, 16, 16)
            isAllCaps = false
            
            setOnClickListener {
                handleActionClick(action)
            }
        }
        return button
    }
    
    private fun setupControlButtons() {
        val hideButton = keyboardView.findViewById<Button>(R.id.hideButton)
        val settingsButton = keyboardView.findViewById<Button>(R.id.settingsButton)
        
        hideButton.setOnClickListener {
            requestHideSelf(0)
        }
        
        settingsButton.setOnClickListener {
            // Open keyboard settings
            launchSettings()
        }
    }
    
    private fun insertText(text: String) {
        val inputConnection = currentInputConnection ?: return
        inputConnection.commitText(text, 1)
    }
    
    private fun handleActionClick(action: String) {
        when {
            action.contains("Invoice") -> {
                insertText("📋 Silakan berikan detail pesanan Anda:\n\n1. Nama produk:\n2. Jumlah:\n3. Alamat pengiriman:\n\nKami akan buatkan invoice untuk Anda!")
            }
            action.contains("Stok") -> {
                insertText("📦 Produk yang ingin ditanyakan stoknya:")
            }
            action.contains("Ongkir") -> {
                insertText("🚚 Untuk menghitung ongkir, mohon berikan:\n\n1. Kota tujuan:\n2. Berat paket:\n3. Kurir pilihan (JNE/J&T/SiCepat):")
            }
            action.contains("Kalkulator") -> {
                insertText("💰 Total pesanan Anda:\n\nSubtotal: Rp \nOngkir: Rp \n-----------\nTotal: Rp ")
            }
        }
    }
    
    private fun launchSettings() {
        val intent = packageManager.getLaunchIntentForPackage(packageName)
        intent?.addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }
    
    override fun onStartInputView(info: android.view.inputmethod.EditorInfo?, restarting: Boolean) {
        super.onStartInputView(info, restarting)
        // Refresh templates when keyboard is shown
        setupTemplateButtons()
    }
}