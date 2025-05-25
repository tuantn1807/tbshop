from rasa_sdk import Action
from rasa_sdk.events import SlotSet
from rasa_sdk.executor import CollectingDispatcher
from rasa_sdk import Tracker
import requests
from typing import Any, Text, Dict, List

class ActionGetProductInfo(Action):
    def name(self) -> Text:
        return "action_get_product_info"

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:

        product_name = tracker.get_slot("name")

        firebase_url = "https://book-app-a2432-default-rtdb.firebaseio.com/products.json"
        response = requests.get(firebase_url)

        if response.status_code != 200:
            dispatcher.utter_message(text="Không thể truy xuất dữ liệu từ Firebase.")
            return []

        products = response.json()
        product_list = list(products.values())

        message = ""

        if product_name:
            normalized_product_name = product_name.strip().lower()

            print(f"Product name from user: '{normalized_product_name}'")  # Debug

            product = next((p for p in product_list if normalized_product_name in p.get("name", "").strip().lower()), None)

            if product:
                name = product.get("name", "Không rõ")
                price = product.get("price", "Không rõ")
                quantity = product.get("quantity", "Không rõ")
                discount = product.get("discount", "0")

                if int(quantity) == 0:
                    message = f"Rất tiếc, sản phẩm {name} hiện đã hết hàng."
                else:
                    message = f"Sản phẩm {name} có giá {price}đ, còn {quantity} cái và giảm giá {discount}%. "
            else:
                message = f"Xin lỗi, tôi không tìm thấy sản phẩm '{product_name}'. Bạn có thể thử tìm sản phẩm khác không?"

            print(f"List of products: {[p.get('name', 'Không rõ') for p in product_list]}")

        else:
            message = "Bạn muốn tìm thông tin sản phẩm nào? Ví dụ: giày thể thao, iphone 14, tai nghe bluetooth."

        dispatcher.utter_message(text=message)
        return []
