# GarageStorage

GarageStorage is designed to do two things:
- Simplify Core Data persistance
- Eliminate versioning Core Data datamodels/having to do xcdatamodel migrations

It does this at the expense of speed and robustness. In GarageStorage, there is only one type of Core Data Entity, and all of your NSObjects are mapped into this object. Relations between NSObjects are maintained, so you do get some of the graph features of Core Data. Also, it's super alpha, so you've been warned.
#### Getting Started
First, create a Garage. It's called a Garage because you can park pretty much anything in it, like, you know, your garage. Create a Garage with: `[[GSGarage alloc] init]`. WARNING: You should only ever have one instance of your Garage. Feel free to make it a singleton.
#### Mapping Objects
Any object that you wish to park in your Garage must conform to `<GSMappableObject>`. A `<GSMappableObject>` must implement the method `+ (GSObjectMapping *)objectMapping`. 

An object mapping specifies the properties on the object you wish to have parked. Additionally, it specifies a property which is the unique identifier for your object. This property must be an NSString. For example, I may have a person object that looks like this:
``` 
@interface Person : NSObject <GSMappableObject>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *SSN;

@end
```
You can get a base mapping for a class with: `[GSObjectMapping alloc] initWithClass:[yourClass class]]` The mapping for the Person object might look like:
``` 
+ (GSObjectMapping *)objectMapping {
    GSObjectMapping *mapping = [[GSObjectMapping alloc] initWithClass:[self class]];
    
    [mapping addMappingsFromArray:@[@"name", @"ssn"]];
    [mapping setIdentifyingAttribute:@"ssn"];
    
    return mapping;
}
```
You must set the identifying attribute, or else your objects will not be parked. Under the hood, your object gets serialized to JSON, so for now, don't try to park any tricky properties. Strings, numbers (both NSNumbers and primitives), dictionaries where keys and values are Strings or NSNumbers, GSMappableObjects, and arrays of arbitrary GSMappableObjects/the other types listed here, all those should be fine.

#### Parking/Retrieving/Deleting GSMappableObjects In The Garage
To park (store) a GSMappableObject in the garage, you call `- (void)parkObjectInGarage:(id<GSMappableObject>)object`. This will add the object to the Garage, but it will not save the Garage to the persistent store. To do that, you must call `- (void)saveGarage`. 

To retrieve an object from the Garage, you can either fetch all the objects of a given class with `- (NSArray *)retrieveAllObjectsOfClass:(Class)cls`, or you can fetch an object of a given class and a given identifier with: `- (id<GSMappableObject>)retrieveObjectOfClass:(Class)cls identifier:(NSString *)identifier`.

To delete an object from the Garage, use: ` - (void)deleteObjectFromGarage:(id<GSMappableObject>)object`. To delete all the objects in a Garage, use `- (void)deleteAllObjectsFromGarage`. As with parking objects, deletes are not persisted to disk until you call `- (void)saveGarage`.

#### Notes
That's pretty much it for now. Park things, save the Garage, and you're good to go.
