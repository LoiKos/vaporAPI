<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.6.1/css/font-awesome.min.css">

# <a name="Overview"></a> Overview

This API as been design to be used to test Vapor framework (Swift) performances. 

This API is build to work with a PostgreSQL database and provide a way to interact with stores and products through an relational model.

<i class="fa fa-book" aria-hidden="true"></i>

## [Doc :book:](#Doc)  |  [Docker :whale:](#Docker)  |   [Code Coverage :shield:](#Cov) |  [Task Flow 🔨](#Tasks) 

# <a name="Doc"></a> Api Documentation

 [Stores](#Stores) | [Products](#Products) | [Stock](#Stock) | [Errors](#Error)

## <a name="Stores"></a> Stores

URL        :  ` api/v1/stores ` |  ` api/v1/stores/:id `

Method     :  ` GET `,` POST `  |  ` DELETE ` , ` PATCH ` ` GET `

URL Params :      none          |   id: required

Parameters :  ` Limit ` and ` Offet ` with GET  | None

Request body Structure : 
```swift
// Store obj
{
   "refStore": String   //  Auto generated do not modify
   "name": String,      //  required
   "picture":String,    //  optional
   "vat":Double,        //  optional
   "currency":String,   //  optional
   "merchantkey":String //  optional
} 
```

Code 

#### Code: 200 OK

Content: 

```swift
// Store obj
{
   "refStore": String   //  Auto generated do not modify
   "name": String,      //  required
   "picture":String,    //  optional
   "vat":Double,        //  optional
   "currency":String,   //  optional
   "merchantkey":String //  optional
} 
```
OR

```swift
[
   {
      "refStore": String   //  Auto generated do not modify
      "name": String,      //  required
      "picture":String,    //  optional
      "vat":Double,        //  optional
      "currency":String,   //  optional
      "merchantkey":String //  optional
   },{
      "refStore": String   //  Auto generated do not modify
      "name": String,      //  required
      "picture":String,    //  optional
      "vat":Double,        //  optional
      "currency":String,   //  optional
      "merchantkey":String //  optional
   }
   ,...
] 
```

#### Code: 201 CREATED

Content: 
```swift
// Store obj
{
   "refStore": String   //  Auto generated do not modify
   "name": String,      //  required
   "picture":String,    //  optional
   "vat":Double,        //  optional
   "currency":String,   //  optional
   "merchantkey":String //  optional
} 
```

### <a name="Products"></a> Products

URL        :  ` api/v1/products ` |  ` api/v1/products/:id `

Method     :  ` GET `,` POST `  |  ` DELETE ` , ` PATCH ` ` GET `

URL Params :      none          |   id: required

Parameters :  ` Limit ` and ` Offet ` with GET  | None

Request body Structure : 
```swift
// Product obj
{
   "refproduct": String //  Auto generated do not modify
   "name": String,      //  required
   "picture":String,    //  optional
   "creationdate":Date //  Auto generated do not modify
} 
```

Code 

#### Code: 200 OK

Content: 

```swift
// Product obj
{
   "refproduct": String //  Auto generated do not modify
   "name": String,      //  required
   "picture":String,    //  optional
   "creationdate":Date //  Auto generated do not modify
} 
```
OR

```swift
[
   // Product obj
{
   "refproduct": String //  Auto generated do not modify
   "name": String,      //  required
   "picture":String,    //  optional
   "creationdate":Date //  Auto generated do not modify
},{
   "refproduct": String //  Auto generated do not modify
   "name": String,      //  required
   "picture":String,    //  optional
   "creationdate":Date //  Auto generated do not modify
} 
   ,...
] 
```

#### Code: 201 CREATED

Content: 
```swift
// Product obj
{
   "refproduct": String //  Auto generated do not modify
   "name": String,      //  required
   "picture":String,    //  optional
   "creationdate":Date //  Auto generated do not modify
} 
```

### <a name="Stock"></a> Stock

URL        :  ` api/v1/stores/:storeId/products ` |  ` api/v1/stores/:storeId/products/:productId `

Method     :  ` GET `,` POST `  |  ` DELETE ` , ` PATCH ` ` GET `

URL Params :      storeId: required          |   storeId:   required, productId: required

Parameters :  ` Limit ` and ` Offet ` with GET  | None


Request body Structure : 
```swift
// Stock obj
{
   "product_refproduct": String //  Auto generated do not modify
   "product_name": String,      //  required
   "product_picture":String,    //  optional
   "product_creationdate":Date, //  Auto generated do not modify
   "refproduct":String,
   "refstore":String,
   "quantity":Int,
   "vat":Double,
   "priceht":Double,
   "status":String,
   "creationdate":Date,
   "lastupdate":Date
} 
```

Code 

#### Code: 200 OK

Content: 

```swift
// Stock obj
{
   "product_refproduct": String //  Auto generated do not modify
   "product_name": String,      //  required
   "product_picture":String,    //  optional
   "product_creationdate":Date, //  Auto generated do not modify
   "refproduct":String,
   "refstore":String,
   "quantity":Int,
   "vat":Double,
   "priceht":Double,
   "status":String,
   "creationdate":Date,
   "lastupdate":Date
} 
```
OR

```swift
[
   // Product obj
// Stock obj
{
   "product_refproduct": String //  Auto generated do not modify
   "product_name": String,      //  required
   "product_picture":String,    //  optional
   "product_creationdate":Date, //  Auto generated do not modify
   "refproduct":String,
   "refstore":String,
   "quantity":Int,
   "vat":Double,
   "priceht":Double,
   "status":String,
   "creationdate":Date,
   "lastupdate":Date
} ,{
   "product_refproduct": String //  Auto generated do not modify
   "product_name": String,      //  required
   "product_picture":String,    //  optional
   "product_creationdate":Date, //  Auto generated do not modify
   "refproduct":String,
   "refstore":String,
   "quantity":Int,
   "vat":Double,
   "priceht":Double,
   "status":String,
   "creationdate":Date,
   "lastupdate":Date
}
   ,...
] 
```

#### Code: 201 CREATED

Content: 
```swift
// Stock obj
{
   "product_refproduct": String //  Auto generated do not modify
   "product_name": String,      //  required
   "product_picture":String,    //  optional
   "product_creationdate":Date, //  Auto generated do not modify
   "refproduct":String,
   "refstore":String,
   "quantity":Int,
   "vat":Double,
   "priceht":Double,
   "status":String,
   "creationdate":Date,
   "lastupdate":Date
}
```

### <a name="Error"></a> API Error

#### Code: 400 BAD REQUEST 

Example : 

- [x] Empty JSON Body for POST or PATCH
          
- [x] Missing required properties POST

- [x] Wrong limit or offset ( < 0 )

#### Code: 404 NOT FOUND 

Example : Id not found in database  

#### Code: 500 INTERNAL SERVER ERROR 


# <a name="Docker"></a> Work with Docker

#### Required images :

```shell 
$ docker pull postgres
```
```shell 
$ docker pull swift
```

#### Launch database container : 
``` shell
$ docker run --name *containerName* -e POSTGRES_PASSWORD=*pwd* -e POSTGRES_USER=*userName* -e POSTGRES_DB=*dbName* -d postgres
```
#### Build image : 

```shell 
$ docker build -t *name* . 
```

#### Launch perfect container : 

```shell
$ docker run -it --rm --link *databaseContainerName*:database -p 8080:8080 -v `pwd`:`pwd` -w `pwd` *perfectImageName*
```

#### Vapor database configuration 

You should update value in Config file postgresql.json to match your database information

# <a name="Cov"></a> Code Coverage

*Coming Soon* 

# <a name="Tasks"></a> Task Flow
- [x] Database connection
- [x] Stores routes
- [x] Products routes 
- [x] Stock routes 
- [x] Docker
- [x] Linux compatibility 
- [x] API docs
- [ ] Unit tests 
- [ ] CI 
- [ ] Code Cov

