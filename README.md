Projeto de Inteligência Artificial Para Jogos Digitais

Alunos: Hélio Lima e Ilo Benevides

Sobre o Projeto:
  O projeto foi feito como um jogo baseado em sistema de turnos com ambos o Protagonista do jogo e os inimigos possuindo uma Máquina de Estados e IA embutida neles para realizar suas ações, 
 dentro de quadrantes, o jogador assiste ao ambiente e escolhe quais upgrades ele vai realizar no Protagonista quando evoluir de nível baseado no contexto atual. Quando certa quantidade de XP for recolhida
 XP for recolhida (coletada por eliminar inimigos) o jogador pode escolher entre melhorar a Vida, o número de Ações ou o Dano de seu personagem, o Protagonista no inicio do jogo possui 4 de Vida, 1 de dano
e 2 ações por turno.

  Inimigos só são ativados dentro de um determinado alcance do protagonista, ao serem ativados eles vão procurar por rastros ou se mover aleatoriamente com o objetivo de eliminar o Protagonista atacando ao
se encontrar do seu lado, inimigos ativos são adicionados na ordem de turnos para realizar suas ações.

  O protagonista assim como os inimigos utilizam um sistema de detecção de rastros para a movimentação, indo atrás do mais relevante no momento de acordo com suas maquinas de estado e se guiando pela
informação mais forte desse rastro para encontrar aonde ele quer chegar, os inimigos só tem interesse em caçar o Protagonista e o Protagonista pode ir atrás de inimigos ou Vida caso com a vida Baixa.

As máquinas de estado do protagonista e Inimigos estão detalhadas em StateMachine.jpeg nos arquivos principais.
