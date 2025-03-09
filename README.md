<p align="center">
  <a href="https://suturo.github.io/suturo_knowledge/">
    <img width="150" src="https://suturo.github.io/suturo_knowledge/assets/images/suturo-knowledge-full-1000.png">
  </a>
</p>

# suturo_knowledge

The SUTURO Knowledge stack is based on [KnowRob](https://github.com/knowrob/knowrob), a knowledge processing system, which provides functionalities to represent knowledge and reasoning methods. We are using it to store, represent and infer rich information about the robots state and its environment.

## Getting started

### Installation guide
Follow the [installation guide](https://github.com/suturo21-22/suturo-installation) to set up the SUTURO Knowledge system on your computer.  
_TODO: Provide updated installation guide_

### Documentation
There is a number of README files formatted in markup description that are part of the SUTURO Knowledge repository. They document the organization of the knowledge modules, their different sub-components and what interfaces they provide.

The documentation is also deployed to the [SUTURO Knowledge Website](https://suturo.github.io/suturo_knowledge/)

### Recommended code editors

- **Visual Studio Code**  
  Install the [`VSC-Prolog`](https://marketplace.visualstudio.com/items?itemName=arthurwang.vsc-prolog) extension to get syntax highlighting and code completion for Prolog in VS Code.

- **Emacs**  
  If you want to edit Prolog with Emacs, use the following command in in the `src` directory:
  ```bash
  find -iname '*.pl' -exec etags --lang=prolog {} +  
  ```
  This will generate a TAGS file that Emacs can use to jump to the definition of a predicate.  
  You can also specify paths to be searched between `find` and `-iname`.  
  The following for example indexes everything from the folder 3 levels up:
  ```bash
  find ../../.. -iname '*.pl' -exec etags --lang=prolog {} +
  ```
  
## confirming installation

```=bash
rosrun suturo_knowledge suturo_knowledge.launch
```

## Testing

To run the (incomplete) unit tests defined in the varoius `.plt` files, use
```
rosrun knowrob knowrob-test.sh suturo_knowledge
```

Instead of suturo_knowledge you can also use the absolute path to the file. For this `$(pwd)` is helpful: `rosrun knowrob knowrob-test.sh "$(pwd)"/shape_workaround.plt`.

---

<p align="center">
  <a href="https://www.uni-bremen.de/">
    <img height="40" src="https://suturo.github.io/suturo_knowledge/assets/images/uni-bremen-logo-footer.png">
  </a>
  <span>&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;</span>
  <a href="https://github.com/suturo">
    <img height="40" src="https://suturo.github.io/suturo_knowledge/assets/images/suturo-logo-footer.png">
  </a>
</p>
