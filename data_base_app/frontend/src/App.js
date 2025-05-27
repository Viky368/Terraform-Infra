import { useState, useEffect } from "react";
import axios from "axios";

function App() {
  const [tab, setTab] = useState("register");
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [users, setUsers] = useState([]);

  const register = async () => {
    await axios.post("http://flask-service:3000/register", { name, email });
    alert("User registered!");
    setName("");
    setEmail("");
    fetchUsers();
  };

  const fetchUsers = async () => {
    const res = await axios.get("http://flask-service:3000/users");
    setUsers(res.data);
  };

  useEffect(() => {
    if (tab === "users") {
      fetchUsers();
    }
  }, [tab]);

  return (
    <div>
      <div style={{ marginBottom: "1rem" }}>
        <button onClick={() => setTab("register")}>Register</button>
        <button onClick={() => setTab("users")}>View Users</button>
      </div>

      {tab === "register" && (
        <div>
          <h1>Register User</h1>
          <input value={name} onChange={(e) => setName(e.target.value)} placeholder="Name" />
          <input value={email} onChange={(e) => setEmail(e.target.value)} placeholder="Email" />
          <button onClick={register}>Submit</button>
        </div>
      )}

      {tab === "users" && (
        <div>
          <h2>Registered Users</h2>
          <ul>
            {users.map((user, index) => (
              <li key={index}>{user.name} - {user.email}</li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
}

export default App;