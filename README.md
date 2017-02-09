# SoundCloud Challenge

This app challenge was to design and develop a 4 x 4 card memory game using the provided internal Sound Cloud API. This app was designed with the intent to allow the user to replay the game once completed.

## Structure of App
- The app grouping is separated by group (Views, Controllers, Data Store).
- I utilized Dependency Inversion for the data store for a more modular implementation.
- The views were created programmatically. Storyboard views would have been the ideal design but I wanted to show my understanding of views with this approach.
- I decided to follow MVC over MVVM for this design for simplicity. There wasn't much delegation required in the View Controller so it avoided the problem of having a massive View Controller.
- For loading the data from the Sound Cloud API, I went with a flexible solution for the network layer so I could properly utilize it to retrieve the Track Data as well as the Track Art.
 
## Challenges 
- The SoundCloud API only provided 12 unique images, which was not enough to complete the challenge. I decided to manipulate the data and use only 8 images and repeat them to guarantee every card had a pair.
- I didn't have an image pack for the Icon so I decided to use Snapseed's icon for the app icon and an image from unsplash.com for the card background art.
- I didn't set aside enough time to properly add any unit testing/UI testing. Given more time outside of my current employment, I would've added tests for the possible edge cases.
