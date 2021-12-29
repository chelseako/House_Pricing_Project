
import csv
import re
import time
import datetime
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.common.exceptions import NoSuchElementException


def get_houses(num_houses, num_mos):
    '''Scrapes data from OahuRE.com
       on num_houses sold houses within num_mos sold.
       Returns dataframe'''

    start = time.time()  # Initialize to track total scraping time
    # Starting website initialized to similar listing page of desired property type
    website = 'https://www.oahure.com/NearestPrice.php?PropertyType=RES&MLSAreaMajor=Metro&MLSNumber=202126005&Limit=100'

    s = Service('C:/webdrivers/chromedriver')
    
    options = webdriver.ChromeOptions()
    options.headless = True

    # Initialize webdriver
    driver = webdriver.Chrome(service=s, options = options)
    driver.implicitly_wait(5)
    driver.get(website)
    
    # default path to file to store data
    path_to_file = "/Users/cnaga/Desktop/houses.csv"
    
    # Initialize mls file
    mls = []
    
    # Open csv file to read existing MLS numbers, if any
    with open(path_to_file) as f:
        reader = csv.reader(f, delimiter=',')
        for i in reader:
            mls.append(i[0])
    
    # Open the file to save the new data
    csvFile = open(path_to_file, 'a', encoding="utf-8", newline="")
    csvWriter = csv.writer(csvFile)
    csvWriter.writerow(['mls_id', 'status', 'soldDate', 'beds',
                        'liveSF', 'landSF', 'region', 'neighborhood',
                        'origPrice', 'daysActive', 'dateListed',
                        'yearBuilt', 'view', 'condition', 'axTotal',
                        'pool', 'topography', 'stories', 
                        'zoning', 'floodZone', 'easements'])

    
    # Initialize number of pages visited to 1
    pageCount = 1

    # Get sold within start date from input num_mos
    num_days = 30*num_mos
    startDate = datetime.datetime.now() - datetime.timedelta(days=num_days)
    print(startDate)

    # Use regular expressions to find sold date in listing
    regex1 = re.compile('\d\d-\d\d-\d\d\d\d')
    
    while len(mls) < num_houses:
    
        if pageCount >= 3:  # Added condition to break if no new houses identified
            print('Exceeded 2 pages. Needed {}, got {}.'.format(num_houses, len(mls)))
            break
        
        try:        
            houseLinks = driver.find_elements(By.XPATH, '//ul/li/a[1]')
            #print('Length of houseLinks: ', len(houseLinks))
            time.sleep(5)
        
        except NoSuchElementException:
            print('Scraping terminated early. Needed {}, got {}.'.format(num_houses, len(mls)))
            break

        listCount = 0
        
        for house in houseLinks:
            
            listCount += 1
            if len(mls) >= num_houses:
                break
            
            #print('\nClicking on house link #: ', listCount)
            house.click()

            # Switch to opened window, referenced by pageCount
            driver.switch_to.window(driver.window_handles[pageCount])
            
            try: 
                
                # Check if property is not already in list
                mls_id = driver.find_element(By.XPATH, "//*[contains(text(), 'MLS#')]/following-sibling::*[1]").text
                
                # Get property status text
                status = driver.find_element(By.XPATH, "//*[contains(text(), 'Status')]/following-sibling::*[1]").text
                
                # Get sold date to check if sold within num_mos from current date
                soldDateStr = regex1.search(status).group(0)
                soldDate = datetime.datetime.strptime(soldDateStr, '%m-%d-%Y')
                
                # Confirm property status is sold
                sold = re.search('Sold', status)
                
                # Get region to confirm in Diamond Head or Metro
                region = driver.find_element(By.XPATH, "//td[contains(text(), 'Region')]/following-sibling::*[1]").text
                DH = re.search('Diamond Head', region)
                Metro = re.search('Metro', region)
                
                # Check if property meets all conditions
                if (mls_id in mls) or (soldDate < startDate) or (sold is None) or (not DH and not Metro):
                    print('MLS already in list or sold > 1 year ago or not sold or not in region.')                    
                
                else:
                    mls.append(mls_id)
                
                    
                    try:
                        beds = driver.find_element(By.XPATH, "//td[contains(text(), 'Beds')]/following-sibling::*[1]").text
                    except NoSuchElementException:
                        beds = -1
                       
                    try:
                        liveSF = driver.find_element(By.XPATH, "//td[contains(text(), 'Living Sq Ft')]/following-sibling::*[1]").text
                    except NoSuchElementException:
                        liveSF = -1
                        
                    try:
                        landSF = driver.find_element(By.XPATH, "//td[contains(text(), 'Land Sq Ft')]/following-sibling::*[1]").text
                    except NoSuchElementException:
                        landSF = -1
                        
                    try:
                        neighborhood = driver.find_element(By.XPATH, "//td[contains(text(), 'Neighborhood')]/following-sibling::*[1]").text
                    except NoSuchElementException:
                        neighborhood = -1
                    
                    try:
                        origPrice = driver.find_element(By.XPATH, "//td[contains(text(), 'Original')]/following-sibling::*[1]").text
                    except NoSuchElementException:
                        origPrice = -1
                        
                    try:
                        daysActive = driver.find_element(By.XPATH, "//td[contains(text(), 'days in Active')]").text
                    except NoSuchElementException:
                        daysActive = -1
                        
                    try:
                        dateListed = driver.find_element(By.XPATH, "//*[contains(text(), 'Listed')]").text
                    except NoSuchElementException:
                        dateListed = -1
                        
                    try:
                        yearBuilt = driver.find_element(By.XPATH, "//td[contains(text(), 'Year Built')]/following-sibling::*[1]").text
                    except NoSuchElementException:
                        yearBuilt = -1
                        
                    try:
                        view = driver.find_element(By.XPATH, "//td[contains(text(), 'View')]/following-sibling::*[1]").text
                    except NoSuchElementException:
                        view = -1
                    
                    try:
                        condition = driver.find_element(By.XPATH, "//td[contains(text(), 'Condition')]/following-sibling::*[1]").text
                    except NoSuchElementException:
                        condition = -1
                        
                    try:
                        axTotal = driver.find_element(By.XPATH, "//td[contains(text(), 'Assessed Total')]/following-sibling::*[1]").text
                    except NoSuchElementException:
                        axTotal = -1
                        
                    try:
                        pool = driver.find_element(By.XPATH, "//td[contains(text(), 'Pool')]/following-sibling::*[1]").text
                    except NoSuchElementException:
                        pool = -1
                        
                    try:
                        topography = driver.find_element(By.XPATH, "//td[contains(text(), 'Topography')]/following-sibling::*[1]").text
                    except NoSuchElementException:
                        topography = -1
                    
                    try:
                        stories = driver.find_element(By.XPATH, "//td[contains(text(), 'Stories')]/following-sibling::*[1]").text
                    except NoSuchElementException:
                        stories = -1
                    
                    try:
                        zoning = driver.find_element(By.XPATH, "//td[contains(text(), 'Residential District')]").text
                    except NoSuchElementException:
                        zoning = -1
                        
                    try:
                        floodZone = driver.find_element(By.XPATH, "//td[contains(text(), 'Zone')]").text
                    except NoSuchElementException:
                        floodZone = -1
                    
                    try:
                        easements = driver.find_element(By.XPATH, "//td[contains(text(), 'Easements')]/following-sibling::*[1]").text
                    except NoSuchElementException:
                        easements = -1
                    
                    print("\nMLS: {}, # houses {}".format(mls_id, len(mls)))

                    csvWriter.writerow([mls_id, status, soldDate, beds, liveSF,
                                        landSF, region, neighborhood, origPrice, 
                                        daysActive, dateListed, yearBuilt, 
                                        view, condition, axTotal,
                                        pool, topography, stories, 
                                        zoning, floodZone, easements])
         
            except NoSuchElementException:
                pass

            # If end of the page listings is reached, get new list.
            if listCount == len(houseLinks):
                print('\nGetting new list')
                
                try:        
                    driver.find_element(By.PARTIAL_LINK_TEXT, "Similar Listings").click()
                    driver.close()
                    driver.switch_to.window(driver.window_handles[pageCount])
                    pageCount += 1
                    break
                    
                except NoSuchElementException:
                    print('Scraping terminated early. Needed {}, got {}.'.format(num_houses, len(mls)))
                    break
                               
            else:
                
                driver.close()
                driver.switch_to.window(driver.window_handles[(pageCount-1)])    
    
    csvFile.close()
    driver.quit()
    
    total = time.time() - start
    
    print('Total time: ', total)

get_houses(1000)


