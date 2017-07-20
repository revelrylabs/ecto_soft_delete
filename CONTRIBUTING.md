# Setup for Development

```
git clone https://github.com/revelrylabs/ecto_soft_delete
mix deps.get
```

# Submitting Changes

1. Fork the repository.
2. Set up the package per the instructions above and ensure `mix test`
   runs cleanly.
3. Create a topic branch.
4. Add specs for your unimplemented feature or bug fix.
5. Run `mix test`. If your specs pass, return to step 4.
6. Implement your feature or bug fix.
7. Re-run `mix test --cover`. If your specs fail, return to step 6.
8. Open cover/modules.html. If your changes are not completely covered by the
   test suite, return to Step 4.
9. Thoroughly document and comment your code.
10. Run `mix docs` and make sure your changes are documented.
11. Add, commit, and push your changes.
12. Submit a pull request.
