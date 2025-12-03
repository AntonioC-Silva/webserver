async function carregarFilmes() {
  try {
    const resposta = await fetch("/filmes.json");
    if (!resposta.ok) throw new Error('Falha ao carregar filmes.json');
   
    const filmes = await resposta.json();
   
    const container = document.getElementById("ListaFilmes");
    container.innerHTML = "";
 
    if (!filmes || filmes.length === 0) {
      container.innerHTML = `
        <p>Não há filmes cadastrados no momento.</p>
        <p>Adicione seus filmes ao sistema!</p>
      `;
      return;
    }
 
    filmes.forEach((f, index) => {
      const card = document.createElement("div");
      card.classList.add("filmeCard");

      card.innerHTML = `
        <h3>${f.nome} <span class="anoFilme">(${f.ano})</span></h3>
        <p><strong>Diretor:</strong> ${f.diretor}</p>
        <p><strong>Gênero:</strong> ${f.genero}</p>
        <p><strong>Produtora:</strong> ${f.produtora}</p>
        <p><strong>Atores:</strong> ${f.atores}</p>
        <p><strong>Sinopse:</strong> ${f.sinopse}</p>
        <div class="acoesCard">
          <button class="botaoPequeno" onclick="editarFilme(${index})">Editar</button>
          <button class="botaoPequeno" onclick="deletarFilme(${index})">Excluir</button>
        </div>
      `;
      container.appendChild(card);
    });
  } catch (erro) {
    console.error("Erro ao carregar filmes:", erro);
    const container = document.getElementById("ListaFilmes");
    container.innerHTML = `<p style="color: red;">Erro ao carregar os filmes. Verifique o console.</p>`;
  }
}
 
async function deletarFilme(index) {
  if (!confirm("Tem certeza que deseja excluir este filme?")) return;
 
  try {
    const resposta = await fetch("/delete", {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: `index=${index}`
    });
    alert(await resposta.text());
    carregarFilmes();
  } catch(error) {
    console.error("Erro ao deletar:", error);
    alert("Não foi possível deletar o filme.");
  }
}
 
async function editarFilme(index) {
  try {
    const resposta = await fetch("/filmes.json");
    const filmes = await resposta.json();
    const filme = filmes[index];
 
    const novoNome = prompt("Nome do filme:", filme.nome) || filme.nome;
    const novosAtores = prompt("Atores:", filme.atores) || filme.atores;
    const novoDiretor = prompt("Diretor:", filme.diretor) || filme.diretor;
    const novoAno = prompt("Ano:", filme.ano) || filme.ano;
    const novoGenero = prompt("Gênero:", filme.genero) || filme.genero;
    const novaProdutora = prompt("Produtora:", filme.produtora) || filme.produtora;
    const novaSinopse = prompt("Sinopse:", filme.sinopse) || filme.sinopse;
 
 
    const params = new URLSearchParams({
      index,
      nome: novoNome,
      atores: novosAtores,
      diretor: novoDiretor,
      ano: novoAno,
      genero: novoGenero,
      produtora: novaProdutora,
      sinopse: novaSinopse
    });
 
    const resp = await fetch("/edit", {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: params.toString()
    });
 
    alert(await resp.text());
    carregarFilmes();
  } catch(error) {
    console.error("Erro ao editar:", error);
    alert("Não foi possível editar o filme.");
  }
}

async function cadastrarFilme(event) {
    event.preventDefault(); 

    const form = event.target;
    const formData = new FormData(form);
    const params = new URLSearchParams(formData);

    try {
        const resposta = await fetch("/cadastro", {
            method: "POST",
            body: params
        });


        const dados = await resposta.json();

        if (resposta.ok) {
            alert(dados.mensagem);
            window.location.href = "/ListarFilmes"; 
        } else {
            alert("Atenção: " + dados.mensagem);
        }

    } catch (erro) {
        console.error("Erro:", erro);
        alert("Erro ao tentar cadastrar. Verifique o servidor.");
    }
}
 
document.addEventListener("DOMContentLoaded", carregarFilmes);