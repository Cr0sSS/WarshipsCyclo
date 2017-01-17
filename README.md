# WarGamingCiclo
World of Warships wiki based on original WarGaming API.

Actual data for every unit:
- SHIPS (include events, specials and test ones that could'n be seen in client app)
- MODULES
- UPGRADES

At first object opening App will request, parse and save unit info to CoreData.
Next openings App will check version of unit info (CoreData & Wiki Server) and update if needed.

# Project contains
- Pods (AFNetworking, KTCenterFlowLayout)
- CoreData
- Autolayout
- UIKit
- Foundation

# Requirements 
- Xcode 8.2.1 или новее
- iOS 10.2 или новее

# Licence
The MIT License (MIT)

Copyright (c) 2016 Andrey Kuznetsov

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
