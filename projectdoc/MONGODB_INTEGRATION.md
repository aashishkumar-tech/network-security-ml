# MongoDB Integration Documentation

## 📦 Overview

This project uses **MongoDB Atlas** as the primary data storage for phishing detection dataset. MongoDB provides a cloud-based, scalable, and flexible NoSQL database solution.

## 🔧 Configuration

### Database Details

```python
DATABASE_NAME: "AashishKumarTechDB"
COLLECTION_NAME: "NetworkData"
CONNECTION_STRING: Stored in .env file
```

### Environment Variables

File: `.env`

```env
MONGO_DB_URL=mongodb+srv://username:password@cluster.mongodb.net/
MONGODB_URL_KEY=mongodb+srv://username:password@cluster.mongodb.net/
```

## 📝 Data Schema

The collection stores phishing detection features with the following structure:

### Features (30 columns)

- `having_IP_Address`: IP address in URL indicator
- `URL_Length`: Length of URL
- `Shortining_Service`: URL shortener usage
- `having_At_Symbol`: @ symbol presence
- `double_slash_redirecting`: Redirect indicators
- `Prefix_Suffix`: Dash in domain
- `having_Sub_Domain`: Subdomain count
- `SSLfinal_State`: SSL certificate status
- `Domain_registeration_length`: Domain age
- `Favicon`: Favicon loading status
- `port`: Non-standard port usage
- `HTTPS_token`: HTTPS in domain
- `Request_URL`: External resource loading
- `URL_of_Anchor`: Anchor tag analysis
- `Links_in_tags`: Link density
- `SFH`: Server form handler
- `Submitting_to_email`: Email submission
- `Abnormal_URL`: URL abnormality
- `Redirect`: Redirect count
- `on_mouseover`: Mouse events
- `RightClick`: Right-click disabled
- `popUpWidnow`: Pop-up windows
- `Iframe`: Iframe usage
- `age_of_domain`: Domain age
- `DNSRecord`: DNS record status
- `web_traffic`: Site traffic rank
- `Page_Rank`: PageRank value
- `Google_Index`: Google indexing
- `Links_pointing_to_page`: Backlink count
- `Statistical_report`: Statistical analysis
- `Result`: **Target variable** (-1: phishing, 1: legitimate)

## 🔄 Data Pipeline

### 1. **Uploading Data to MongoDB**

File: `push_data.py`

```python
class NetworkDataExtract:
    def csv_to_json_convertor(file_path):
        """Convert CSV to JSON format"""
        
    def insert_data_mongodb(records, database, collection):
        """Insert records into MongoDB"""
```

**Usage:**

```bash
python push_data.py
```

**Process:**

1. Reads CSV from `Network_Data/phisingData.csv`
2. Converts to JSON format
3. Inserts into MongoDB collection
4. Returns count of inserted records

### 2. **Fetching Data from MongoDB**

File: `networksecurity/components/data_ingestion.py`

```python
def export_collection_as_dataframe():
    """
    Fetch data from MongoDB and convert to DataFrame
    """
    # Connect to MongoDB
    mongo_client = pymongo.MongoClient(MONGO_DB_URL)
    collection = mongo_client[database_name][collection_name]
    
    # Fetch and convert
    df = pd.DataFrame(list(collection.find()))
    df.drop(columns=["_id"], axis=1)  # Remove MongoDB ID
    
    return df
```

**Features:**

- Automatic connection handling
- Error handling with custom exceptions
- Data validation (empty check)
- Logging of record count

## 🛠️ Implementation Details

### Connection Management

```python
import pymongo
import certifi

ca = certifi.where()  # SSL certificate verification
client = pymongo.MongoClient(MONGO_DB_URL, tlsCAFile=ca)
```

### Error Handling

```python
try:
    collection = mongo_client[database_name][collection_name]
    df = pd.DataFrame(list(collection.find()))
    
    if len(df) == 0:
        raise Exception("No data found in MongoDB")
        
except Exception as e:
    raise NetworkSecurityException(e, sys)
```

### Data Preprocessing

After fetching from MongoDB:

1. Remove `_id` column (MongoDB internal)
2. Replace "na" strings with `np.nan`
3. Validate data shape
4. Log record count

## 📊 MongoDB Atlas Setup

### Prerequisites

1. Create MongoDB Atlas account
2. Create a cluster (free tier available)
3. Setup database user with read/write permissions
4. Whitelist IP address (0.0.0.0/0 for development)

### Connection String Format

```
mongodb+srv://<username>:<password>@<cluster>.mongodb.net/?appName=<cluster-name>
```

## ✅ Advantages of MongoDB

1. **Flexible Schema**: Easy to modify data structure
2. **Scalability**: Horizontal scaling with sharding
3. **Cloud-Native**: Managed service with automatic backups
4. **High Availability**: Built-in replication
5. **Rich Queries**: Powerful aggregation pipeline
6. **JSON-Like Documents**: Natural fit for Python dictionaries

## 🔐 Security Best Practices

1. ✅ Credentials in `.env` file (not committed)
2. ✅ SSL/TLS encryption enabled
3. ✅ Database user with minimal permissions
4. ✅ IP whitelist configuration
5. ✅ Connection string never hardcoded

## 🐛 Common Issues & Solutions

### Issue: Connection Timeout

**Solution:** Check IP whitelist in MongoDB Atlas

### Issue: Authentication Failed

**Solution:** Verify username/password in `.env` file

### Issue: Empty DataFrame

**Solution:** Run `python push_data.py` to upload data first

### Issue: SSL Certificate Error

**Solution:** Use `certifi` library for certificate verification

## 📈 Performance Considerations

- **Batch Operations**: Insert multiple records at once
- **Indexing**: Create indexes on frequently queried fields
- **Connection Pooling**: Reuse connections
- **Data Validation**: Validate before insertion

## 🔗 Related Files

- `push_data.py` - Upload data to MongoDB
- `networksecurity/components/data_ingestion.py` - Fetch from MongoDB
- `networksecurity/constant/training_pipeline/__init__.py` - Configuration
- `.env` - Connection credentials
