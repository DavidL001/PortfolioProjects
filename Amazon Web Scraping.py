# Goal for this project is to pull price data from Amazon for a 4090 Nvidia Graphics Card and automate the data into a csv daily
from bs4 import BeautifulSoup
import requests
import smtplib
import time
import datetime
import csv
import pandas as pd

# Pulling the data from the link of the amazon item (product title and price)
URL = "https://www.amazon.com/PNY-GeForce-Gaming-Overclocked-Graphics/dp/B0BHCJKGKS/ref=sr_1_3?crid=AUN55ZQPFBFW&dib=eyJ2IjoiMSJ9.FvtyHB-Dk_p8c8rTn9aU32XCzbExOxiXVNdqJg8Sl44Oj9XOrXwMkfwjRFROcHT9Ufo0ymfH0phh0H6zMMTDZNUjCa5zZ-IglrdnLIaCXkIfaPy3g8ZZJnsf-uvQUPWbnugdScE9lfJPdqw-FFaSAy_whKvq3tTijNIZHETCjSV0-Gi4wYdyV0q-u51w0mUX7l8k-9blTcxHND0HMnlVJ2pHhqgpMkRAhZ2LPYJgOPE.RGy1hBMiu3Vx7u8t_ElPzkl5hL_u-XNz0ADeDPZ9wFU&dib_tag=se&keywords=nvidia%2B4090&qid=1716154249&sprefix=nvidia%2B4090%2Caps%2C115&sr=8-3&th=1"

page = requests.get(URL)

page.raise_for_status()

data = page.text

# print(data)

soup_1 = BeautifulSoup(data, "html.parser")
# print(soup_1)

soup_2 = BeautifulSoup(soup_1.prettify(), "html.parser")
# print(soup_2)

# Let's pull the exact data I want, the title and price of the product
title = soup_2.find(id="productTitle").get_text().strip().replace("™", "")
# print(title)

price_str_int = soup_2.find("span", attrs={"class": "a-price-whole"}).get_text(
    strip=True
)
# print(price_str_int)

price_str_dec = soup_2.find("span", attrs={"class": "a-price-fraction"}).get_text(
    strip=True
)
# print(price_str_dec)

price_comb = price_str_int + price_str_dec
# print(price_comb)

# Price is being pulled in a currency format, to make it easier to use in the future let's convert it into a float
def currency_to_float(money_str):
    try:
        strip_str = money_str.replace("$", "").replace(",", "")
        curr_dec = float(strip_str)
        return curr_dec
    except ValueError:
        print("Invalid price format")
        return 0.0


date = datetime.date.today()
# print(date)

price_float = currency_to_float(price_comb)
# print(title)
# print(price_float)

# Now let's setup a csv that will automatically be updated with product price daily
header = ["Product_Name", "Price", "Date"]
data = [title, price_float, date]

# Initial data insert
with open("AmazonWebScrappingPrices.csv", "w", newline="", encoding="UTF-8") as f:
    writer = csv.writer(f)
    writer.writerow(header)
    writer.writerow(data)

df = pd.read_csv(
    r"C:\Users\dlugo\Desktop\Job Materials\Portfolio Projects\Amazon Web Scrapping\AmazonWebScrappingPrices.csv"
)
print(df)


# Now we are going to append data to the CSV created so we can track the item's price daily

with open(
    r"C:\Users\dlugo\Desktop\Job Materials\Portfolio Projects\Amazon Web Scrapping\AmazonWebScrappingPrices.csv",
    "a+",
    newline="",
    encoding="UTF-8",
) as f:
    writer = csv.writer(f)
    writer.writerow(data)


# Now let's automate this to udpate every day by itself


def check_price():
    URL = "https://www.amazon.com/PNY-GeForce-Gaming-Overclocked-Graphics/dp/B0BHCJKGKS/ref=sr_1_3?crid=AUN55ZQPFBFW&dib=eyJ2IjoiMSJ9.FvtyHB-Dk_p8c8rTn9aU32XCzbExOxiXVNdqJg8Sl44Oj9XOrXwMkfwjRFROcHT9Ufo0ymfH0phh0H6zMMTDZNUjCa5zZ-IglrdnLIaCXkIfaPy3g8ZZJnsf-uvQUPWbnugdScE9lfJPdqw-FFaSAy_whKvq3tTijNIZHETCjSV0-Gi4wYdyV0q-u51w0mUX7l8k-9blTcxHND0HMnlVJ2pHhqgpMkRAhZ2LPYJgOPE.RGy1hBMiu3Vx7u8t_ElPzkl5hL_u-XNz0ADeDPZ9wFU&dib_tag=se&keywords=nvidia%2B4090&qid=1716154249&sprefix=nvidia%2B4090%2Caps%2C115&sr=8-3&th=1"
    page = requests.get(URL)
    page.raise_for_status()
    data = page.text
    soup_1 = BeautifulSoup(data, "html.parser")
    soup_2 = BeautifulSoup(soup_1.prettify(), "html.parser")
    title = soup_2.find(id="productTitle").get_text().strip().replace("™", "")
    price_str_int = soup_2.find("span", attrs={"class": "a-price-whole"}).get_text(
        strip=True
    )
    price_str_dec = soup_2.find("span", attrs={"class": "a-price-fraction"}).get_text(
        strip=True
    )
    price_comb = price_str_int + price_str_dec

    def currency_to_float(money_str):
        try:
            strip_str = money_str.replace("$", "").replace(",", "")
            curr_dec = float(strip_str)
            return curr_dec
        except ValueError:
            print("Invalid price format")
            return 0.0

    date = datetime.date.today()
    price_float = currency_to_float(price_comb)
    header = ["Product_Name", "Price", "Date"]
    data = [title, price_float, date]
    with open(
        r"C:\Users\dlugo\Desktop\Job Materials\Portfolio Projects\Amazon Web Scrapping\AmazonWebScrappingPrices.csv",
        "a+",
        newline="",
        encoding="UTF-8",
    ) as f:
        writer = csv.writer(f)
        writer.writerow(data)


while True:
    check_price()
    time.sleep(86400)
