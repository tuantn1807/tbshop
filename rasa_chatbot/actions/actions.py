from typing import Any, Text, Dict, List
from rasa_sdk import Action, Tracker
from rasa_sdk.executor import CollectingDispatcher
import requests
import re
from fuzzywuzzy import process

class ActionGetProductInfo(Action):
    def name(self) -> Text:
        return "action_get_product_info"

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:

        product_name = tracker.get_slot("name")
        category_name = tracker.get_slot("category")

        firebase_url = "https://book-app-a2432-default-rtdb.firebaseio.com/products.json"
        response = requests.get(firebase_url)

        if response.status_code != 200:
            dispatcher.utter_message(text="Không thể truy xuất dữ liệu từ Firebase.")
            return []

        products = response.json()
        product_list = list(products.values())

        # Tập hợp từ khóa sản phẩm
        product_keywords = set()
        for p in product_list:
            name = p.get("name", "")
            words = re.findall(r'\w+', name.lower())
            product_keywords.update(words)

        def find_best_match(name, choices, key=lambda x: x):
            names = [key(c).lower() for c in choices]
            match, score = process.extractOne(name.lower(), names)
            if score >= 70:
                matched_index = names.index(match)
                return choices[matched_index]
            return None

        def find_top_matches(name, choices, key=lambda x: x, limit=3):
            names = [key(c).lower() for c in choices]
            matches = process.extract(name.lower(), names, limit=limit)
            results = []
            for match, score in matches:
                if score >= 50:
                    matched_index = names.index(match)
                    results.append(choices[matched_index])
            return results

        def clean_text_dynamic(text):
            words = re.findall(r'\w+', text.lower())
            important_words = [word for word in words if word in product_keywords]
            cleaned = ' '.join(important_words)
            return cleaned

        message = ""

        if product_name:
            # Tìm sản phẩm
            product = find_best_match(product_name, product_list, key=lambda p: p.get("name", ""))

            if not product:
                cleaned_name = clean_text_dynamic(product_name)
                product = find_best_match(cleaned_name, product_list, key=lambda p: p.get("name", ""))

            if product:
                name = product.get("name", "Không rõ")
                price = product.get("price", "Không rõ")
                quantity = product.get("quantity", "Không rõ")
                discount = product.get("discount", "0")

                if int(quantity) == 0:
                    message = f"Rất tiếc, sản phẩm {name} hiện đã hết hàng."
                else:
                    message = f"Sản phẩm {name} có giá {price}đ, còn {quantity} cái và giảm giá {discount}%."

            else:
                # Nếu không tìm thấy, gợi ý những sản phẩm gần nhất
                top_matches = find_top_matches(product_name, product_list, key=lambda p: p.get("name", ""))
                if top_matches:
                    message = "Xin lỗi, tôi không tìm thấy sản phẩm chính xác. Bạn có muốn tìm những sản phẩm gần giống này không?\n"
                    for p in top_matches:
                        message += f"- {p.get('name', 'Không rõ')}\n"
                else:
                    message = f"Xin lỗi, TBShop chưa có sản phẩm giống '{product_name}'. Bạn có thể nhập tên sản phẩm khác không?"
                    # Tự học nhẹ: ghi log tên sản phẩm chưa có (giả sử lưu file)
                    with open("unknown_products.txt", "a", encoding="utf-8") as f:
                        f.write(product_name + "\n")

        elif category_name:
            matched_products = [p for p in product_list if category_name.lower() in p.get("category_name", "").lower()]
            if matched_products:
                message = f"Các sản phẩm thuộc danh mục '{category_name}':\n"
                for p in matched_products:
                    name = p.get("name", "Không rõ")
                    price = p.get("price", "Không rõ")
                    quantity = p.get("quantity", "Không rõ")
                    discount = p.get("discount", "0")
                    message += f"- {name}: {price}đ, còn {quantity} cái, giảm {discount}%\n"
            else:
                message = f"Không tìm thấy sản phẩm nào trong danh mục '{category_name}'. Bạn có muốn xem danh mục gần giống không?"

        else:
            message = "Bạn muốn tìm theo tên sản phẩm hay danh mục nào?"

        dispatcher.utter_message(text=message)
        return []
