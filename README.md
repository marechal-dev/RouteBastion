# RouteBastion: A VRP API's Broker

So, this is my Master Thesis project, a Broker for Vehicle Routing Problem (VRP) APIs from different Cloud Providers.

## Project Structure

### Docs

Diagrams and other documentation for the project.

- DB Docs: <https://dbdocs.io/pietro.developer/RouteBastionDB>

### Packages

Source code.

You can run it by:

- Give the execution permission to the `setup.sh` and `run.sh` scripts:
  
```sh
chmod +x ./Scripts/setup.sh
chmod +x ./Scripts/stop.sh
chmod +x ./Scripts/run.sh
```

- Run the `setup.sh` script **once**:

```sh
./Scripts/setup.sh
```

- Run the `run.sh` script:

```sh
./Scripts/run.sh
```

If you want to type less, you can create an alias to run the `run.sh`, like:

```sh
alias sbrk="./Scripts/stop.sh"
alias brk="./Scripts/run.sh"
```

### Papers

The scientific papers I wrote during the development of this project (it may be outdated since I mainly use Overleaf for that and I don't want to pay only to connect with GitHub).
