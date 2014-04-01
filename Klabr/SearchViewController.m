//
//  SearchViewController.m
//  Klabr
//
//  Created by Sanchit Chadha on 3/30/14.
//  Copyright (c) 2014 Sanchit Chadha. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()

@property (nonatomic, strong) NSString *SERVER_IP;
@property (nonatomic, strong) NSString *PORT;
@property (nonatomic, strong) NSMutableData *googleResponseData;
@property (nonatomic, strong) NSMutableData *serverResponseData;
@property (nonatomic, strong) NSURLConnection *googleConnection;
@property (nonatomic, strong) NSURLConnection *serverConnection;
@property (nonatomic, strong) NSMutableDictionary *tableCellsDict;

@property (nonatomic, strong) NSMutableArray *names;
@property (nonatomic, strong) NSMutableArray *addresses;
@property (nonatomic, strong) NSMutableArray *num_users;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *longitude;

@property (nonatomic, strong) NSString *selectedName;

@end

@implementation SearchViewController

static NSString *const API_KEY = @"AIzaSyDJhytcECfUZ64UX-PqFPifGJc5gvrhppk";

- (void)viewDidLoad
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.SERVER_IP = appDelegate.SERVER_IP;
    self.PORT = appDelegate.PORT;
    self.userData = appDelegate.userData;
    
    self.tableCellsDict = [[NSMutableDictionary alloc] init];
    
//    [self getLocation];
    [self setUpView];
    [super viewDidLoad];
}

- (void)NumClientsTask:(NSMutableArray*)roomList
{
    NSString *post = [NSString stringWithFormat:@"rooms=%@",
                      [self convertArray:roomList]];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@:%@/chat/clients", self.SERVER_IP, self.PORT]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    self.serverConnection = [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)SearchTask:(NSString*)URL
{
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:URL]];
    self.googleConnection = [NSURLConnection connectionWithRequest:request delegate:self];
}

- (IBAction)searchButton:(UIButton *)sender {
//    [self getLocation];
    if (![[self.searchField text] isEqualToString:@""]) {
        [self SearchTask:[self placesURLBuilder]];
        [self.searchField resignFirstResponder];
    }
}

-(NSString *)placesURLBuilder {
    NSString *replaceQuery = [[self.searchField text] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?"];
    url = [url stringByAppendingFormat:@"location=%@,%@&", @"37.214956", @"-80.449642"];//self.latitude, self.longitude];
    url = [url stringByAppendingFormat:@"radius=50000&"];
    url = [url stringByAppendingFormat:@"rankBy=distance&"];
    url = [url stringByAppendingFormat:@"name=%@&", replaceQuery];
    url = [url stringByAppendingFormat:@"sensor=true&"];
    url = [url stringByAppendingFormat:@"key=%@", API_KEY];
    return url;
}

- (NSString *)convertArray:(NSMutableArray *)array
{
    NSString *result = [NSString stringWithFormat:@""];
    
    for (int i = 0; i < [array count]; i++) {
        if (i != [array count] - 1) {
            result = [result stringByAppendingFormat:@"%@\t", [array objectAtIndex:i]];
        }
        else {
            result = [result stringByAppendingString:[array objectAtIndex:i]];
        }
    }
    return result;
}


#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    if (connection == self.serverConnection) {
        self.serverResponseData = [[NSMutableData alloc] init];
    }
    else {
        self.googleResponseData = [[NSMutableData alloc] init];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    if (connection == self.serverConnection) {
        [self.serverResponseData appendData:data];
    }
    else {
        [self.googleResponseData appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    NSError *error = nil;
    
    NSDictionary *jsonDictionary = [[NSDictionary alloc] init];
    NSString *name;
    NSString *address;
    NSString *key;
    
    /*
     NSMUTABLEDICTIONARY
     
     NAME (ADDRESS)
        -VALUE1 (Address)
        -VALUE2 (Num Users)
     
     FOOD LION (100 PRICES FORKS)
        -100 PRICES FORKS
        -1
     */
    
    if (connection == self.serverConnection) {
        self.num_users = [[NSMutableArray alloc] init];
        jsonDictionary = [NSJSONSerialization JSONObjectWithData:self.serverResponseData options:kNilOptions error:&error];
        self.num_users = [jsonDictionary objectForKey:@"num_clients"];
        [self.tableView reloadData];
    }
    else {
        self.names = [[NSMutableArray alloc] init];
        self.addresses = [[NSMutableArray alloc] init];
        jsonDictionary = [NSJSONSerialization JSONObjectWithData:self.googleResponseData options:kNilOptions error:&error];
        NSArray *results = [jsonDictionary objectForKey:@"results"];
        
        if ([results count] == 0) {
            self.num_users = [[NSMutableArray alloc] init];
            [self.names addObject:@"No results found"];
            [self.num_users addObject:@""];
            [self.tableView setUserInteractionEnabled:NO];
            [self.tableView reloadData];
        }
        else {
            [self.tableView setUserInteractionEnabled:YES];
            for (int i = 0; i < [results count]; i++) {
                name = [[results objectAtIndex:i] objectForKey:@"name"];
                address = [[[[results objectAtIndex:i] objectForKey:@"vicinity"] componentsSeparatedByString:@","] objectAtIndex:0];
                if (address == nil) {
                    address = @"No Address Available";
                }
                key = [NSString stringWithFormat:@"%@ (%@)", name , address];
                key = [key stringByReplacingOccurrencesOfString:@"&" withString:@"and"];
                [self.names addObject:key];
                [self.addresses addObject:address];
            }
            [self NumClientsTask:self.names];
        }
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Connection Error"
                          message:@"There seems to be a problem with the server, try again later."
                          delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - UITableViewDataSource Protocol Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.names count];
}

// Customize the appearance of the table view cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Reference to each cell based on the on the cell identifier, movieCell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"placesCell"];
    
    // Configure the cell
    NSUInteger rowNumber = [indexPath row];
    
    
    // Sets the textLabel and detailTextLabel of the cell
    [cell.textLabel setFont:[UIFont systemFontOfSize:14.0]];
    cell.textLabel.text = [self.names objectAtIndex:rowNumber];
    
    if ([[NSString stringWithFormat:@"%@", [self.num_users objectAtIndex:0]] isEqualToString:@""]) {
        cell.detailTextLabel.text = @"";
    }
    else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Number of users: %@", [self.num_users objectAtIndex:rowNumber]];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate Protocol Methods

// Tapping a row (movie) displays the trailer associated with that movie.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"SELECTED ROW %ld", (long)[indexPath row]);
    
    self.selectedName = [self.names objectAtIndex:[indexPath row]];
    
    [self performSegueWithIdentifier:@"ChatRoom" sender:self];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *segueIdentifier = [segue identifier];
    
    if ([segueIdentifier isEqualToString:@"ChatRoom"]) {
        ChatViewController *chatView = [segue destinationViewController];
        chatView.userData = self.userData;
        chatView.roomName = self.selectedName;
    }
}

- (void)getLocation {
    if ([CLLocationManager locationServicesEnabled] == NO) {
        
        // Create the Alert View
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled"
                                                        message:@"Turn Location Services On in your device settings to be able to use location services."
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:nil];
        
        // Display the Alert View
        [alert show];
        
        return;
    }
    
    // Instantiate a CLLocationManager object and store its object reference
    self.locationManager = [[CLLocationManager alloc] init];
    
    // Set the current view controller to be the delegate of the location manager object
    self.locationManager.delegate = self;
    
    // Set the location manager's distance filter to kCLDistanceFilterNone implying that
    // a location update will be sent regardless of movement of the device
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    
    // Set the location manager's desired accuracy within ten meters of the desired target
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    
    // Start the generation of updates that report the user’s current location.
    // Implement the protocol method below to receive and process the location info.
    
    [self.locationManager startUpdatingLocation];
}


#pragma mark - CLLocationManager Delegate Methods

// Tells the delegate that a new location data is available
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    /*
     The objects in the given locations array are ordered with respect to their occurrence times.
     Therefore, the most recent location update is at the end of the array; hence, we access the last object.
     */
    CLLocation *currentLocation = [locations lastObject];
    
    // Obtain current location's latitude in degrees (as a double value)
    self.latitude = [NSString stringWithFormat:@"%f", currentLocation.coordinate.latitude];
    
    // Obtain current location's longitude in degrees (as a double value)
    self.longitude = [NSString stringWithFormat:@"%f", currentLocation.coordinate.longitude];
    
    // Stops the generation of location updates since we do not need it anymore
    [manager stopUpdatingLocation];
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    /*
     The kCLErrorLocationUnknown error implies that the manager is currently unable to get the location.
     We can ignore this error for the scenario of getting a single location fix, because we already
     have a timeout that will stop the location manager to save power.
     */
    if ([error code] == kCLErrorLocationUnknown) {
        
        // Create the Alert View
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to Obtain Your Location"
                                                        message:@"Your location could not be determined!"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:nil];
        
        // Display the Alert View
        [alert show];
        
        // Stop the generation of location updates since we do not need it anymore
        [manager stopUpdatingLocation];
    }
}

- (void)setUpView
{
    CGFloat *range = (CGFloat*)malloc(sizeof(CGFloat) * 2);
    range[0] = 0.0f;
    range[1] = 1.0f;
    
    self.searchButton.rounding = 8.0f;
    self.searchButton.colors = @[[UIColor colorWithRed:91.0f/255 green:192.0f/255 blue:222.0f/255 alpha:1]];
    [self.searchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.searchButton.selectedColors = @[[UIColor blueColor]];
    self.searchButton.disabledColors = @[[UIColor lightGrayColor]];
    self.searchButton.corners = UIRectCornerAllCorners;
    self.searchButton.colorRange = range;
    
    CGRect rect = CGRectMake(16, 75, 224, 30);
    BTTextField *searchField = [[BTTextField alloc] initWithFrame:rect];
    searchField.borderWidth = 1.5;
    searchField.borderColor = [UIColor colorWithRed:91.0f/255 green:192.0f/255 blue:222.0f/255 alpha:1];
    searchField.bodyColor = [UIColor colorWithWhite:0.95 alpha:1];
    searchField.placeholder = @"Search Points Of Interest";
    searchField.font = [UIFont systemFontOfSize:14];
    searchField.autocorrectionType = UITextAutocorrectionTypeDefault;
    searchField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    searchField.clearsOnBeginEditing = YES;
    searchField.selectedBorderColor = [UIColor colorWithRed:91.0f/255 green:192.0f/255 blue:222.0f/255 alpha:1];
    [self.view addSubview:searchField];
    
    self.searchField = searchField;
}
@end
