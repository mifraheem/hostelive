import google.generativeai as genai
import sys

# === Gemini Configuration ===
API_KEY = 'AIzaSyB-5WGFyxG3QmJDDFADGoILaEfzKWMACGo'

try:
    genai.configure(api_key=API_KEY)
    model = genai.GenerativeModel(
        model_name="gemini-2.0-flash-exp",
        generation_config={
            "temperature": 0.7,
            "top_p": 0.95,
            "top_k": 40,
            "max_output_tokens": 2048,
            "response_mime_type": "text/plain",
        }
    )
except Exception as e:
    print(f"❌ Failed to configure Gemini AI: {e}")
    sys.exit(1)

# === Chatbot Runner ===
def run_chat():
    try:
        chat = model.start_chat()
        print("🧠 Gemini Terminal Chatbot\n(Type your message and press Enter. Use Ctrl+D to send multiline input)\n")

        while True:
            try:
                print("You:")
                user_input = sys.stdin.read().strip()
                if not user_input:
                    continue
                response = chat.send_message(user_input)
                print("\nGemini:\n" + response.text + "\n")

            except (EOFError, KeyboardInterrupt):
                print("\n👋 Exiting chat.")
                break

    except Exception as e:
        print(f"❌ Chat error: {e}")

# === Entry Point ===
if __name__ == '__main__':
    run_chat()
