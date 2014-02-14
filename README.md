#im-runnable

Learn you some InterMine Web Services for good.

a) Make requests client side using JavaScript.

*Advantages*: easiest, fastest, "securest" (no security needed).
*Disadvantages*: limited to JavaScript only; if we want to be able to
embed these somewhere as a "widget" then maybe it is not a problem.
"Only" JavaScript allows you to write client side
widgets/apps/components.

b) Make requests server side in a Node.js (JavaScript) sandbox.

*Advantages*: there is a nice project we can utilize to create a sandbox
for each app/user, so it is quite easily done.
*Disadvantages*. only JavaScript; slow-ish (not sure what the advantage
of routing through server is).

c) Write server side sandboxes for each new programming language we
would like to add.

*Advantage*: plethora of languages
*Disadvantages*: takes time to implement them all and I don't think it
is worth it. I can understand that people like Python, but we are
constrained on time here and this is not our main project...; slow-ish

d) Write a server side Java sandbox and run other programming languages in it.

*Advantage*: not that bad to implement, certainly easier than (c)
*Disadvantages*: other languages need to be easily runnable through Java
incl packaging systems like NPM for Node.js etc., slow-ish