# The Brick Library - Terminal User Interfaces in Haskell

#### Ben Hart

What is a Terminal user interface?

 - not a Graphic interface
 - not a CLI
 - runs in terminal
 - think 'ncurses'
 - some similar apps - tig, ranger, vim, emacs, nmtui

_________

# What is the Brick library?

- Uses State Monad and IO monad to create an FRP environment
- Typically uses cursors over some data structure to navigate menus and options
- a great place for someone new to haskell to build their first non-trivial app

_________

# How does the Brick library work?

start  --> State --> Draw
              ^        |
              |        |
           Event  <---/

- Brick uses an event based FRP framework to draw widgets based on a state type
- The draw is a pure function from state
- Events can be handled in IO - so we can perform effects

_________

# Basic brick structure in types

1) `State` - defines the type of our state
2) `Event` - the type of our events,   there are built-in events for most user interactions, and you can build custom event streams and add those too if you want. (such as emitting an event when an HTTP call succeeds or is received, file watch updates, etc.)
3) `ResourceName` - used for defining a resource which will be safely closed when the brick application closes.  this is called bracket pattern
4) `App s e n` - defines the type of the Application as a whole as a product of our state type, our event type, and our Resources.

- today, we'll look at an app that uses a simple state and the default events.

https://github.com/NorfairKing/tui-base

_________

what is the structure of the `App` at the term level?

```
data App s e n = 
  { appDraw :: s -> [Widget n]
  , appHandleEvent :: s -> BrickEvent n e -> EventM n (Next s)
  , appAttrMap :: s -> AttrMap
  }
```

- you can think of `EventM` as IO
- `AttrMap` is a way to do styling
- Widget is sort of like `show` it is a type that knows how to draw itself.

