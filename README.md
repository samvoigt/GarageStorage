# GarageStorage

GarageStorage is designed to do two things:
- Simplify Core Data persistance
- Eliminate versioning Core Data datamodels/having to do xcdatamodel migrations

It does this at the expense of speed and robustness. In GarageStorage, there is only one type of Core Data Entity, and all of your NSObjects are mapped into this object. Relations between NSObjects are maintained, so you do get some of the graph features of Core Data. Also, although it's in production apps, it's not super heavily tested, and doesn't do much error checking for bad inputs, so you've been warned.

#### Getting Started
First, create a Garage. It's called a Garage because you can park pretty much anything in it, like, you know, your garage. Create a Garage with: `[[GSGarage alloc] init]`. WARNING: You should only ever have one instance of your Garage. Feel free to make it a singleton. Or not.
```ObjC
@property (nonatomic, strong) GSGarage *garage;
```
```ObjC
self.garage = [GSGarage new];
```
#### What is a Garage?
Your `GSGarage` is the central manager that coordinates the use of Garage Storage. It handles the backing Core Data stack, as well as the saving and retrieving of data. *The Managed Object Context used by your Garage exists on the thread you created the Garage on. It's highly recommended that you use Garage Storage on the main thread.* You "Park" objects in the Garage, and "Retrieve" them later. Any object going into or coming out of the Garage must subscribe to `GSMappableObject` protocol. We'll get into the details on that later. For now, it's important to draw a distinction between how Garage Storage functions and how Core Data functions: Garage Storage stores a JSON representation of your objects in Core Data, as opposed to storing the objects themselves, as core data does. There are some implications to this (explained below), but the best part is that you can add whatever type of object you like to the Garage, whenever you like. You don't have to migrate data models or anything, just park what you want!

#### Mapping Objects
Any object that you wish to park in your Garage must conform to `<GSMappableObject>`. A `<GSMappableObject>` must implement the method `+ (GSObjectMapping *)objectMapping`. 

An object mapping specifies the properties on the object you wish to have parked. Additionally, it may specify a property which is the unique identifier for your object. This property must be an NSString. For example, I may have a person object that looks like this:
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
    mapping.identifyingAttribute = @"ssn";
    
    return mapping;
}
```
Once you have set the properties to map, you should set the identifying attribute, at least for top-level objects (See note about Identifying Attributes below). Under the hood, your object gets serialized to JSON, so for now, don't try to park any tricky properties. Strings, numbers (both `NSNumbers` and primitives), dates, dictionaries where keys and values are Strings or `NSNumbers`, `GSMappableObjects`, and arrays of arbitrary `GSMappableObjects`/the other types listed here, are fine. 

#### Parking Objects
Parking an object puts a snapshot of that object into the Garage. As mentioned, this is different from pure Core Data, where changes to your `NSManagedObjects` are directly reflected in the MOC. With GarageStorage, since you're parking a snapshot, *you will need to park that object any time you want changes you've made to it to be reflected/persisted.* You can park the same object multiple times, which will update the existing object of that Class and Identifier. To park (store) a `GSMappableObject` in the garage, call:
```ObjC
[self.garage parkObjectInGarage:myPerson];
```
You may also park an array of objects in the garage (assuming all are `GSMappableObjects`:
```ObjC
[self.garage parkObjectsInGarage:@[myBrother, mySister, myMom, myDad]];
```

#### Retrieving Objects
To retrieve a specific object from the garage, you must specify its Class and its identifier.
```ObjC
Person *myPerson = [self.garage retrieveObjectOfClass:[Person class] identifier:@"123-45-6789"];
```
You can also retrieve all objects for a given class:
```ObjC
NSArray *allPeople = [self.garage retrieveAllObjectsOfClass:[Person class]];
```

#### Deleting Objects
To delete an object from the Garage, you must specify the mappable object that was originally parked:
```ObjC
[self.garage deleteObjectFromGarage:myPerson];
```
To delete all objects of a Class, use:
```ObjC
[self.garage deleteAllObjectsFromGarageOfClass:[Person class]];
```
You can also delete all the objects from the Garage:
```ObjC
[self.garage deleteAllObjectsFromGarage];
```

#### Sync Status
If you want to track the sync status of an object (with respect to say, a webservice), you can implement the `GSSyncableObject` protocol, which just requires that your object has a sync status property:
```ObjC
@property (nonatomic) GSSyncStatus syncStatus;
```
Garage Storage provides the following sync status options:
```ObjC
GSSyncStatusUndetermined,
GSSyncStatusNotSynced,
GSSyncStatusSyncing,
GSSyncStatusSynced 
```
Objects conforming to `GSSyncableObject` will have their sync status automatically set when they are parked in the Garage. However, you can also manually set the sync status:
```ObjC
- (BOOL)setSyncStatus:(GSSyncStatus)syncStatus forObject:(id<GSMappableObject>)object;
- (BOOL)setSyncStatus:(GSSyncStatus)syncStatus forObjects:(NSArray *)objects;
```
(Those functions will return `NO` if one or more of the objects was not found in the garage.)

You can also determine the sync status of an object in the garage:
```ObjC
- (GSSyncStatus)syncStatusForObject:(id<GSMappableObject>)object;
```

And most importantly, you can retrieve objects from the garage based on sync status:
```ObjC
- (NSArray *)retrieveObjectsWithSyncStatus:(GSSyncStatus)syncStatus;
- (NSArray *)retrieveObjectsWithSyncStatus:(GSSyncStatus)syncStatus ofClass:(Class)cls;
```

#### Saving The Store
Parking, deleting, or modifying the sync status of objects does not, in and of themselves, persist their changes to disk. However, `autosaveEnabled` is set to `YES` by default in a `GSGarage`. This means that any operation that modifies the garage will also trigger a save of the garage. If you don't want this enabled, then set `autosaveEnabled` to `NO`, and then explicitly save the Garage by calling:
```ObjC
[self.garage saveGarage];

```
##### A Note about Identifying Attributes
It's worth going into a bit of detail about how Identifying Attributes work so you can best leverage (read: account for the quirks of) Garage Storage. Any object with an identifying attribute will be stored as its own separate object in the Garage. This is great if you have a bunch of objects that reference each other, as the graph is properly maintained in the garage, so a change to one object will be "seen" by the other objects pointing to it. 

Alternatively, you don't have to set an identifying attribute on your object. If you do this on a top level object (i.e. one that you call `parkObject` on directly), the mapping's JSON representation of the object becomes its identifier. If you park unidentified Object A, then change one of its properties, and park Object A again, you'll now have 2 "copies" of Object A in the Garage. If Object A had had an identifier, then Object A would have just been updated when it was parked the 2nd time. It's considered best practice for top-level objects to have an identifying attribute.

However, if your object is instead a property of a top-level object, you may want to have it be unidentified. An unidentified property object is serialized as in-line JSON, instead of having a separate underlying core data object, as an identified object would. This means you won't be able to query those objects by class directly.

The primary advantage of unidentified objects lies in how deletion is handled. When you delete an object from the Garage, only the top level `GSMappableObject` is deleted. If it points to other `GSMappableObjects`, those are not deleted. Garage Storage doesn't monitor retain counts on objects, so for safety, only the object specified is removed. However, since unidentified objects are part of the top level object's JSON, and are not separate underlying objects, they will be removed. It's considered best practice for sub objects to be unidentified unless there is a compelling reason otherwise.

There's some more stuff the Garage can do, including the ability to use your own `persistentStoreCoordinator` (which is useful for encryption purposes), so poke around `GSGarage.h` for more info. Feature/Pull requests are always welcome. Have fun!
