(Get-WmiObject -class win32_printer -Filter "Name='ChooseYourPrinter'").SetDefaultPrinter()