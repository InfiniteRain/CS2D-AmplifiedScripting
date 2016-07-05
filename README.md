# CS2D-AmplifiedScripting
CS2D Amplified Scripting, a CS2D scripting API created for more efficient mod development.

As we all know, standard API of CS2D is very bad and inefficient. First of all, it handles the images/objects/players by their ID's which
are numeric, that means that when a player leaves, an image gets freed or an object gets killed, their ID's might get occupied by other, 
newly created images/objects or joined players, which always tend to create a lot of various bugs in the code. This API is designed to
avoid such errors by using classes and instances (basic OOP). That means that instead of numeric ID's, images/objects/players get handled
by instances (or objects) which you can create whenever you need them, so when you use a lot of, for example, images, whenever you free
said image, the instance of this image will become unusable and will throw an error if you try to use it after disposing of it. This API
also changes the outputted values by the hooks so that instead of numeric ID's, they will get converted into corresponding instances.

Another example is that in the standard API, the only way to control majority of things is to use console commands via "parse" function,
which means that you have to integrate needed values into strings and even put some of them into quotation marks so that if one of your
parameters is a string with a space, it won't count as two seperate parameters. Such way of controlling things is extremely annoying and
this API takes care of that. Every possible console command that is used to control anything is now integrated as methods (functions) of
corresponding instances. So, for example, instead of writing " parse('setpos '.. player ..' '.. x ..' '.. y) ", you just write
" player:setPosition(x, y) ".

There are a lot of really good features and the list would get too long if I would try and list them all. Just try and see it for 
yourself!