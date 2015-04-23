# GarageStorage

GarageStorage is designed to do two things:
- Simplify Core Data persistance
- Eliminate versioning Core Data datamodels/having to do xcdatamodel migrations

It does this at the expense of speed and robustness. In GarageStorage, there is only one type of Core Data Entity, and all of your NSObjects are mapped into this object. Relations between NSObjects are maintained, so you do get some of the graph features of Core Data. Also, it's super alpha, so you've been warned.
#### Getting Started
First, create a Garage. It's called a Garage because you can park pretty much anything in it, like, you know, your garage. Create a Garage with: `[[GSGarage alloc] init]`. WARNING: You should only ever have one instance of your Garage. Feel free to make it a singleton. Or not.
```ObjC
@property (nonatomic, strong) GSGarage *garage;
```
```ObjC
self.garage = [GSGarage new];
```

#### Mapping Objects
Any object that you wish to park in your Garage must conform to `<GSMappableObject>`. A `<GSMappableObject>` must implement the method `+ (GSObjectMapping *)objectMapping`. 

An object mapping specifies the properties on the object you wish to have parked. Additionally, it specifies a property which is the unique identifier for your object. This property must be an NSString. For example, I may have a person object that looks like this:
```ObjC 
@interface Person : NSObject <GSMappableObject>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *SSN;

@end
```
You can get a base mapping for a class with: `[GSObjectMapping mappingForClass:[yourClass class]]` The mapping for the Person object might look like:
```ObjC 
+ (GSObjectMapping *)objectMapping {
    GSObjectMapping *mapping = [GSObjectMapping mappingForClass:[self class]];
    
    [mapping addMappingsFromArray:@[@"name", @"ssn"]];
    [mapping setIdentifyingAttribute:@"ssn"];
    
    return mapping;
}
```
Once you have set the properties to map, you must set the identifying attribute, or else your objects will not be parked. Under the hood, your object gets serialized to JSON, so for now, don't try to park any tricky properties. Strings, numbers (both NSNumbers and primitives), dictionaries where keys and values are Strings or NSNumbers, GSMappableObjects, and arrays of arbitrary GSMappableObjects/the other types listed here, all those should be fine.

#### Parking Objects
To park (store) a GSMappableObject in the garage, call:
```ObjC
[self.garage parkObjectInGarage:myPerson];
```

#### Retrieving Objects
To retrieve an object from the garage, you must specify its Class and its identifier.
```ObjC
Person *myPerson = [self.garage retrieveObjectOfClass:[Person class] identifier:@"123-45-6789"];
```
You can also retrieve all objects for a given class:
```ObjC
NSArray *allPeople = [self.garage retrieveAllObjectsOfClass:[Person class]];
```

To delete an object from the Garage, you must specify the mappable object that was originally parked:
```ObjC
[self.garage deleteObjectFromGarage:myPerson];
```
You can also delete all the objects from the Garage:
```ObjC
[self.garage deleteAllObjectsFromGarage];
```

Both parking and deleting objects do not, in and of themselves, persist their changes to disk. In order to save the garage to the permanent store, you must explicitly save the garage:
```ObjC
[self.garage saveGarage];

```
